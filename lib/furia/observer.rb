# frozen_string_literal: true

module Furia
  module Observer
    def self.wrap(scope)
      @root_scope ||= { uid: "root", type: "group", scope: scope, total_queries_num: 0, total_duration_ms: 0, entries: [] }
      parent_scope = @current_scope
      @current_scope =
        if parent_scope
          { uid: SecureRandom.hex(16), type: "group", scope: scope, total_duration_ms: 0, entries: [] }.tap do |new_scope|
            parent_scope[:entries] << new_scope
          end
        else
          @root_scope
        end

      subscriber =
        ActiveSupport::Notifications.subscribe("sql.active_record") do |_, started, finished, _, payload|
          next if payload[:name] == "SCHEMA"

          duration_ms = (finished - started) * 1000
          @current_scope[:total_duration_ms] += duration_ms
          entry = {
            uid: SecureRandom.hex(16),
            type: "query",
            sql: payload[:sql],
            cached: payload[:name] == "CACHE",
            duration_ms: duration_ms,
            stacktrace: trace_cleaner.clean(caller),
          }.freeze

          @current_scope[:entries] << entry
          @root_scope[:total_queries_num] += 1
        end

      yield.tap do
        if parent_scope
          parent_scope[:total_duration_ms] += @current_scope[:total_duration_ms]
          @current_scope = parent_scope
        else
          Furia::Sample.create!(data: @root_scope)
        end
      end
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end

    def self.trace_cleaner
      @trace_cleaner ||=
        ActiveSupport::BacktraceCleaner.new.tap do |c|
          c.add_silencer { |line| line.include?("/gems/") }
          c.add_silencer { |line| line.include?("/ruby/") }
          c.add_silencer { |line| line.include?("/active_record/") }
        end
    end
  end
end
