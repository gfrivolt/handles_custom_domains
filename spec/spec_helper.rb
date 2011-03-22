require 'rspec'
require 'shoulda'
require 'factory_girl'
require 'faker'
require 'rails'
require 'active_record'
require 'active_support'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

# Establish DB Connection
config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'db', 'database.yml')))
ActiveRecord::Base.configurations = {'test' => config[ENV['DB'] || 'sqlite3']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])

# Load Test Schema into the Database
load("#{File.dirname(__FILE__)}/db/schema.rb")
require File.dirname(__FILE__) + '/../init'

# require 'requestactor'
require 'handles_custom_domains'
# require 'handles_custom_domains/request_processor'
# require 'handles_custom_domains/db_dump_generator'

# Example handles_custom_domains Model:
class CustomDomain < ActiveRecord::Base
  handles_custom_domains :app => 'example_app', :credentials => {:user => 'username@somewhere.com', :key => '123456'}
end

# Load Factories:
Dir[File.join(File.dirname(__FILE__), "factories/**/*.rb")].each {|f| require f}

Rspec.configure do |c|
  c.mock_with :rspec
end
