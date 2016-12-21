
module SqlQueriesCount

   class Railtie < Rails::Railtie
     config.sql_queries_count = ActiveSupport::OrderedOptions.new
     config.sql_queries_count.enabled = true

     config.after_initialize do |app|
       next unless app.config.sql_queries_count.enabled

       SqlQueriesCount::QueryCounter.attach_to :active_record
       ActiveSupport.on_load(:action_controller) do
         include SqlQueriesCount::ControllerRuntime
       end
     end
   end
end
