require 'requestactor/request_processor'

ActiveRecord::Base.class_eval do
  def self.table_name_prefix
    RequestProcessor.current_table_name_prefix || ''
  end
end

ActionController::Base.class_eval do
  before_filter :process_request

  define_method(:process_request) do
    RequestProcessor.processor(request)
  end
end
