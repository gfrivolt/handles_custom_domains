require 'spec_helper'

describe HandlesCustomDomains::SelectsDataset do

  before do
    CustomDomain.delete_all
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

      it 'returns table_name_prefix' do
        Article.table_name_prefix.should == 'foo_'
      end

      it 'has correct table_name' do
        Article.table_name.should == 'foo_articles'
      end

      it 'changes table_name after changing the dataset again' do
        bar_domain.select_as_dataset
        Article.table_name.should == 'bar_articles'
      end

      it 'does not return table_name_prefix for the custom_domain model' do
        CustomDomain.table_name_prefix.should == ''
      end

    end

    context 'for switching between two datasets' do
      before :each do
        ActiveRecord::Base.stub!(:table_name).and_return('foo_articles')
        # foo_domain.select_as_dataset
        # 2.times do
        #   article = Article.new
        #   article.save
        # end
        2.times { Factory.create(:article) }
        ActiveRecord::Base.stub!(:table_name).and_return('bar_articles')
        # bar_domain.select_as_dataset
        # 3.times do
        #   article = Article.new
        #   article.save
        # end
        3.times { Factory.create(:article) }
      end

      # it 'works with the right dataset after selection' do
      #   foo_domain.select_as_dataset
      #   Article.count.should == 2
      #   bar_domain.select_as_dataset
      #   Article.count.should == 3
      # end
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
end

