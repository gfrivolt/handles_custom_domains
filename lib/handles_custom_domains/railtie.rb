require 'handles_custom_domains'
require 'handles_custom_domains/selects_dataset'

module HandlesCustomDomains
  if defined?(Rails::Railtie)
    require "rails"
    
    class Railtie < Rails::Railtie
      initializer "has_draft.extend_active_record" do
        ActiveSupport.on_load(:active_record) do
          HandlesCustomDomains::Railtie.insert
        end
      end
    end
  end
  
  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, HandlesCustomDomains)
      ActiveRecord::Base.send(:include, SelectsDataset)
    end
  end
end
# 
# require 'requestactor/request_processor'
# 
# ActiveRecord::Base.class_eval do
#   def self.table_name_prefix
#     RequestProcessor.current_table_name_prefix || ''
#   end
# end
# 
# ActionController::Base.class_eval do
#   before_filter :process_request
# 
#   define_method(:process_request) do
#     RequestProcessor.processor(request)
#   end
# end
