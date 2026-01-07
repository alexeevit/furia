require "furia/engine"

module Furia
  Group =
    Struct.new(:uid, :scope, :total_duration_ms, :total_queries_num, :entries, keyword_init: true) do
      def self.from_hash(hash)
        group_entries = hash[:entries].map { |entry| Furia.entry_from_hash(entry) }
        new(**hash.except(:entries).slice(*members).merge(entries: group_entries))
      end
    end

  Query =
    Struct.new(:uid, :sql, :cached, :duration_ms, :stacktrace, keyword_init: true) do
      def self.from_hash(hash)
        new(**hash.slice(*members))
      end
    end

  def self.entry_from_hash(hash)
    symbolized = hash.transform_keys(&:to_sym)

    case symbolized[:type]
    when "group"
      Group.from_hash(symbolized)
    when "query"
      Query.from_hash(symbolized)
    else
      raise "Unsupported type: `#{symbolized[:type]}'"
    end
  end

  def self.wrap(scope)
    parent_group = store[:current_group]
    if parent_group
      store[:current_group] = { uid: SecureRandom.hex(16), type: "group", scope: scope, total_duration_ms: 0, entries: [] }
      parent_group[:entries] << store[:current_group]
    else
      store[:root_group] = { uid: "root", type: "group", scope: scope, total_queries_num: 0, total_duration_ms: 0, entries: [] }
      store[:current_group] = store[:root_group]
    end

    subscriber = create_subscriber unless parent_group

    yield.tap do
      if parent_group
        parent_group[:total_duration_ms] += store[:current_group][:total_duration_ms]
        store[:current_group] = parent_group
      else
        Furia::Sample.create!(data: store[:root_group])
      end
    end
  ensure
    if subscriber
      ActiveSupport::Notifications.unsubscribe(subscriber)
      clear_store
    end
  end

  def self.create_subscriber
    ActiveSupport::Notifications.subscribe("sql.active_record") do |_, started, finished, _, payload|
      next if payload[:name] == "SCHEMA"

      duration_ms = (finished - started) * 1000
      entry = {
        uid: SecureRandom.hex(16),
        type: "query",
        sql: payload[:sql],
        cached: payload[:name] == "CACHE",
        duration_ms: duration_ms,
        stacktrace: trace_cleaner.clean(caller),
      }.freeze

      store[:current_group][:entries] << entry
      store[:current_group][:total_duration_ms] += duration_ms
      store[:root_group][:total_queries_num] += 1
    end
  end

  def self.trace_cleaner
    @trace_cleaner ||=
      ActiveSupport::BacktraceCleaner.new.tap do |c|
        c.add_silencer { |line| line.include?("/gems/") }
        c.add_silencer { |line| line.include?("/ruby/") }
        c.add_silencer { |line| line.include?("/active_record/") }
      end
  end

  def self.store
    Thread.current[:furia_store] ||= {}
  end

  def self.clear_store
    Thread.current[:furia_store] = {}
  end
end
