require 'erb'

class DbDumpGenerator

  attr_accessor :db_template

  def initialize
    self.db_template = ''
  end

  def generate_dump(args)
    template_erb = ERB.new(self.db_template)
    table_prefix = args[:table_prefix]
    template_erb.result(binding)
  end
end
