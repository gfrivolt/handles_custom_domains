require 'spec_helper'

describe HandlesCustomDomains do

  it "has an application" do
    CustomDomain.app.should == "example_app"
  end

  it "creates domain on heroku" do
    heroku_client = mock('heroku client')
    heroku_client.should_receive(:add_domain).with('example_app', 'newdomain.example.com')
    CustomDomain.stub!(:service_client).and_return(heroku_client)

    CustomDomain.add_domain('newdomain.example.com')
  end

  it "manages domain name registration" do

  end

  it "holds a list of known domains"

  it "destroy domain on heroku"
end
