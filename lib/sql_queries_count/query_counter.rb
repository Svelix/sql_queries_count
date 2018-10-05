module SqlQueriesCount

  class QueryCounter < ActiveSupport::LogSubscriber
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
      ignore = [/^PRAGMA (?!(table_info))/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/, /^SET/]
      return if ignore.any? { |r| event.payload[:sql] =~ r }

      if event.payload[:cached] || event.payload[:name] == 'CACHE'
        self.class.cached_counter += 1
      else
        self.class.counter += 1
      end
    end
  end

end
