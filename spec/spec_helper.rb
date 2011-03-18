require 'rspec'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
# require 'requestactor'
require 'requestactor/request_processor'
require 'requestactor/db_dump_generator'

Rspec.configure do |c|
  c.mock_with :rspec
end
