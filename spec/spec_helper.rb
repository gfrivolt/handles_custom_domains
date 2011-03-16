require 'rspec'
require 'shoulda'

# ENV['RAILS_ENV'] = 'test'
# RAILS_ROOT = "#{File.dirname(__FILE__)}/test_app" unless defined? RAILS_ROOT
# require_relative "test_app/config/environment.rb"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
# require 'requestactor'
require 'request_processor'
require 'db_dump_generator'

Rspec.configure do |c|
  c.mock_with :rspec
end
