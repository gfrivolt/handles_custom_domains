require 'ruby-debug'

class RequestProcessor

  class << self
    attr_accessor :current_table_name_prefix

    def clear!
      self.current_table_name_prefix = nil
    end
  end

  def initialize
    self.server_name_mappings = Array.new
  end

  attr_accessor :server_name_mappings

  def add_server_name(server_name, args)
    if server_name.is_a?(String)
      self.server_name_mappings << { :server_name => %r/^#{server_name.gsub('*','[^.]*')}$/, :properties => args}
    elsif server_name.is_a?(Regexp)
      self.server_name_mappings << { :server_name => server_name, :properties => args }
    else
      fail "The server_name must be a string or a regular expression"
    end
  end

  alias :add_server_mask :add_server_name

  def match_server_name(server_name)
    server_name_mappings.each do |server_name_mapping|
      return server_name_mapping[:properties] if server_name_mapping[:server_name] =~ server_name
    end
    nil
  end

  def process(request)
    return if RequestProcessor.current_table_name_prefix
    properties_for_server = match_server_name(request.server_name)
    RequestProcessor.current_table_name_prefix = properties_for_server[:table_name_prefix] if properties_for_server
  end
end
