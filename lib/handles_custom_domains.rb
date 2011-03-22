require 'heroku'
require 'active_record'
require 'ruby-debug'

module HandlesCustomDomains
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    attr_accessor :app, :credentials

    def handles_custom_domains(options = {})
      return if self.included_modules.include?(HandlesCustomDomains::InstanceMethods)
      include HandlesCustomDomains::InstanceMethods
      validates_uniqueness_of :domain_name
      self.app = options[:app]
      self.credentials = options[:credentials]
      after_save :update_custom_domains
      after_destroy :remove_custom_domain
    end

    def add_domain(domain_name)
      service_client.add_domain(app, domain_name)
    end

    def service_client
      @service_client ||= Heroku::Client.new(credentials[:user], credentials[:key])
    end
  end

  module InstanceMethods

    def app
      self.class.app
    end

    def credentials
      self.class.credentials
    end

    def service_client
      self.class.service_client
    end

    private

    def update_custom_domains
      service_client.add_domain(app, domain_name)
    end

    def remove_custom_domain
      service_client.remove_domain(app, domain_name)
    end
  end
end

require 'handles_custom_domains/railtie'
