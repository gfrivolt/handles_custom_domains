require 'heroku'
require 'active_record'

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

      domain_name_memoize = nil
      after_initialize { domain_name_memoize = domain_name }
      after_save do
        service_client.remove_domain(app, domain_name_memoize) if domain_name_memoize && domain_name_memoize != self.domain_name
        service_client.add_domain(app, domain_name)
        domain_name_memoize = domain_name
      end
      after_destroy { service_client.remove_domain(app, domain_name) }
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
  end
end

require 'handles_custom_domains/railtie'
