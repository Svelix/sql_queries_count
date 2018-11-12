module SqlQueriesCount

  class QueryCounter < ActiveSupport::LogSubscriber
    IGNORE_PAYLOAD_NAMES = ["SCHEMA", "EXPLAIN"]

    def self.counter=(value)
      Thread.current["active_record_sql_count"] = value
    end

    def self.counter
      Thread.current["active_record_sql_count"] ||= 0
    end

    def self.cached_counter=(value)
      Thread.current["active_record_cached_sql_count"] = value
    end

    def self.cached_counter
      Thread.current["active_record_cached_sql_count"] ||= 0
    end

    def self.reset_counter
      rt, self.counter = counter, 0
      rt
    end

    def self.reset_cached_counter
      rt, self.cached_counter = cached_counter, 0
      rt
    end

    def initialize
      super
    end

    def sql(event)
      payload = event.payload

      return if IGNORE_PAYLOAD_NAMES.include?(payload[:name])

      if payload[:cached] || payload[:name] == 'CACHE'
        self.class.cached_counter += 1
      else
        self.class.counter += 1
      end
    end
  end

end
