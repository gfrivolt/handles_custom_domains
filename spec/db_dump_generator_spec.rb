require 'spec_helper'

describe DbDumpGenerator do

  before { subject.db_template = 'fill table prefix "<%= table_prefix %>" here' }

  it "has a db dump template" do
    subject.db_template.should_not be_nil
  end

  it "generates a filled db dump from the template" do
    subject.generate_dump(:table_prefix => 'foo_').should == 'fill table prefix "foo_" here'
  end
end
