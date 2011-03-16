require 'spec_helper'

describe RequestProcessor do

  context "on server name definition" do
    before do
      subject.add_server_name 'foo.com', :table_name_prefix => 'foo_'
      subject.add_server_mask '*.bar.com', :table_name_prefix => 'bar_'
    end

    it "should store a rule for a server name mask" do
      subject.server_name_mappings.should have(2).items
    end

    it "should match added server name" do
      subject.match_server_name('foo.com')[:table_name_prefix].should == 'foo_'
    end

    it "should match server name in a rule defined by a wildcard" do
      subject.match_server_name('www.bar.com')[:table_name_prefix].should == 'bar_'
    end
  end
end
