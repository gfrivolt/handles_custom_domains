require 'heroku'

module HandlesCustomDomains
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    attr_accessor :app, :credentials

    def handles_custom_domains(options = {})
      return if self.included_modules.include?(HandlesCustomDomains::InstanceMethods)
      include HandlesCustomDomains::InstanceMethods
      self.app = options[:app]
      self.credentials = options[:credentials]
    end

    def add_domain(domain_name)
      service_client.add_domain(app, domain_name)
    end

    private

    def service_client
      @service_client ||= Heroku::Client.new(credentials[:user], credentials[:key])
    end
  end

  module InstanceMethods
  end
end

require 'handles_custom_domains/railtie'
