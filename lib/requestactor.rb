
ActiveRecord::Base.class_eval do
  def self.table_name_prefix
    puts %W(SERVER NAME: #{Thread.current[:request].server_name}) if Thread.current[:request]
    ""
  end
end

ActionController::Base.class_eval do
  before_filter :store_request_in_thread

  define_method(:store_request_in_thread) do
    Thread.current[:request] ||= request
  end
end

