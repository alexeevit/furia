require "furia/engine"
require "furia/observer"

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
end
