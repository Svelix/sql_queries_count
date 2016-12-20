
module SqlQueriesCount

  module ControllerRuntime

    extend ActiveSupport::Concern

    protected

    attr_internal :db_runtime

    def process_action(action, *args)
      QueryCounter.reset_counter
      QueryCounter.reset_cached_counter
      super
    end

    def append_info_to_payload(payload)
      super
      if ActiveRecord::Base.connected?
        payload[:db_query_count] = QueryCounter.reset_counter
        payload[:db_cached_query_count] = QueryCounter.reset_cached_counter
      end
    end


    module ClassMethods
      def log_process_action(payload)
        messages, sql_count, sql_cached_count = super, payload[:db_query_count], payload[:db_cached_query_count]
        messages << ("SQL count: %d" % sql_count) if sql_count
        messages << ("SQL count (cached): %d" % sql_cached_count) if sql_cached_count
        messages
      end
    end

  end

end

