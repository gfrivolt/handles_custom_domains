require 'rspec'
require 'shoulda'
require 'factory_girl'
require 'faker'
require 'rails'
require 'active_record'
require 'active_support'
require 'ruby-debug'

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
require 'handles_custom_domains/request_processor'
require 'handles_custom_domains/selects_dataset'

# Example handles_custom_domains Model:
class CustomDomain < ActiveRecord::Base
  handles_custom_domains :app => 'example_app', :credentials => {:user => 'username@somewhere.com', :key => '123456'}
  selects_dataset :by => :table_name_prefix
end

class Article < ActiveRecord::Base
end

def mock_heroku_client_for(*args)
  heroku_client = mock('heroku client')
  args.each do |subject|
    subject.stub!(:service_client).and_return(heroku_client)
  end
  heroku_client
end

# Load Factories:
Dir[File.join(File.dirname(__FILE__), "factories/**/*.rb")].each {|f| require f}

Rspec.configure do |c|
  c.mock_with :rspec
end
