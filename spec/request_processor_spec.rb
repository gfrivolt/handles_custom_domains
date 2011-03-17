require 'spec_helper'
require 'ruby-debug'

describe RequestProcessor do

  before do
    subject.add_server_name 'foo.com', :table_name_prefix => 'foo_'
    subject.add_server_mask '*.bar.com', :table_name_prefix => 'bar_'
  end

  it "stores a rule for a server name mask" do
    subject.server_name_mappings.should have(2).items
  end

  it "matches added server name" do
    subject.match_server_name('foo.com')[:table_name_prefix].should == 'foo_'
  end

  it "matches server name in a rule defined by a wildcard" do
    subject.match_server_name('www.bar.com')[:table_name_prefix].should == 'bar_'
  end

  it "tells nil when matching unknown server name" do
    subject.match_server_name('dontknowthis').should be_nil
  end

  it "catches server name from the browser request" do
    request_mock = mock('browser request')
    request_mock.should_receive(:server_name).once.and_return('www.bar.com')
    subject.process(request_mock)
    RequestProcessor.current_table_name_prefix.should == 'bar_'
  end

  it "stores properties per thread" do
    RequestProcessor.current_table_name_prefix = nil
    Thread.new { RequestProcessor.current_table_name_prefix = 'foo_' }
    RequestProcessor.current_table_name_prefix.should be_nil
  end
end
