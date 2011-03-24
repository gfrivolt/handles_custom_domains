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
end

describe CustomDomain do
  before do
    CustomDomain.delete_all
    @heroku_client = mock_heroku_client_for(subject)
    subject.domain_name = 'newdomain.example.com'
    @heroku_client.should_receive(:add_domain).once.with('example_app', 'newdomain.example.com')
    subject.save
  end

  it "creates new domain when new record is created and the domain not yet registered" do
    subject.valid?.should == true
  end

  it "removes the domain name from heroku when the record is destroyed" do
    @heroku_client.should_receive(:remove_domain).once.with('example_app', 'newdomain.example.com')
    subject.destroy
  end

  it "changes the domain name on heroku when the domain_name field changes" do
    @heroku_client.should_receive(:remove_domain).once.with('example_app', 'newdomain.example.com')
    @heroku_client.should_receive(:add_domain).once.with('example_app', 'otherdomain.example.com')
    subject.domain_name = 'otherdomain.example.com'
    subject.save
  end
end

describe CustomDomain do

  before { CustomDomain.delete_all }

  [:custom_domain1, :custom_domain2].each do |custom_domain_subject|
    let custom_domain_subject do
      custom_domain = CustomDomain.new
      custom_domain.domain_name = "#{custom_domain_subject.to_s}.com"
      custom_domain
    end
  end

  it "creates a new domain record without deleting the previous domain from heroku" do
    heroku_client = mock_heroku_client_for(custom_domain1, custom_domain2)
    heroku_client.should_receive(:add_domain).once.with('example_app', 'custom_domain1.com')
    heroku_client.should_receive(:add_domain).once.with('example_app', 'custom_domain2.com')
    heroku_client.should_not_receive(:remove_domain)
    custom_domain1.save
    custom_domain2.save
  end
end

