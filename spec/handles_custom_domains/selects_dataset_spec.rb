require 'spec_helper'

describe HandlesCustomDomains::SelectsDataset do

  before do
    DatabaseCleaner.clean
    HandlesCustomDomains::SelectsDataset::SharedMethods.clear_cache
  end

  [:foo, :bar].each do |domain_name|
    let "#{domain_name.to_s}_domain".to_sym do
      new_domain = CustomDomain.new
      new_domain.domain_name = "#{domain_name.to_s}.com"
      new_domain.name_prefix = "#{domain_name.to_s}_"
      new_domain
    end
  end

  it 'activates dataset based on the server name' do
    request = mock('incoming request')
    request.should_receive(:server_name).once.and_return('foo.com')
    heroku_client = mock_heroku_client_for(foo_domain, bar_domain)
    heroku_client.stub!(:add_domain)
    foo_domain.save
    bar_domain.save
    CustomDomain.find_matching_domain_for(request).should == foo_domain
  end

  describe 'when enforcing dataset' do
    before :each do
      CustomDomain.clear_dataset_selection!
    end

    context do
      before :each do
        heroku_client = mock_heroku_client_for(foo_domain)
        heroku_client.stub!(:add_domain)
        foo_domain.select_as_dataset
      end

      it 'does not select the same dataset twice' do
        HandlesCustomDomains::SelectsDataset.should_not_receive(:current_dataset=)
        foo_domain.select_as_dataset
      end

      it 'returns table_name_prefix' do
        Article.table_name_prefix.should == 'foo_'
      end

      it 'has correct table_name and quoted_table_name' do
        Article.table_name.should == 'foo_articles'
        Article.quoted_table_name.should == "\"foo_articles\""
      end

      it 'changes table_name and quoted_table_name after changing the dataset again' do
        bar_domain.select_as_dataset
        Article.table_name.should == 'bar_articles'
        Article.quoted_table_name.should == "\"bar_articles\""
      end

      it 'does not return table_name_prefix for the custom_domain model' do
        CustomDomain.table_name_prefix.should == ''
      end

    end

    context 'for switching between two datasets' do
      before :each do
        foo_domain.select_as_dataset
        2.times { Factory.create(:article) }
        bar_domain.select_as_dataset
        3.times { Factory.create(:article) }
      end

      it 'works with the right dataset after selection' do
        foo_domain.select_as_dataset
        Article.count.should == 2
        bar_domain.select_as_dataset
        Article.count.should == 3
      end

      it 'caches database related data and does not recreate table representations after the switches' do
        Arel::Table.should_not_receive(:new).should_not_receive(:engine)
        foo_domain.select_as_dataset
        Article.count
        bar_domain.select_as_dataset
        Article.count
      end
    end
  end

  it 'prohibits to be applied on more classes' do
    lambda do
      class OtherCustomDomain < ActiveRecord::Base
        def table_name
          'custom_domains'
        end
        selects_dataset :by => :table_name_prefix
      end
    end.should raise_error
  end

  describe 'SharedMethods' do
    subject { HandlesCustomDomains::SelectsDataset::SharedMethods }

    it "creates space for new klasses and datasets" do
      subject.cached_attr[Article][foo_domain][:relation] = 5
      subject.cached_attr[Article][foo_domain][:relation].should == 5
    end

    context 'when dataset is selected' do 
      before do
        foo_domain.select_as_dataset
        Article.count
        subject.cache_state_for(Article)
      end

      it "stores selected instance variables" do
        subject.cached_attr[Article][foo_domain].should have_key :column_names
        subject.cached_attr[Article][foo_domain][:column_names].should == ["id", "title", "body"]
      end

      it "restores selected instance variables for the current dataset" do
        Article.class_eval { @column_names = nil }
        subject.restore_state_for(Article)
        subject.cached_attr[Article][foo_domain][:column_names].should == ["id", "title", "body"]
      end
    end
  end
end
