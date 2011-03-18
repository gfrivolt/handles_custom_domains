module HandlesCustomDomains
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def handles_custom_domains
      return if self.included_modules.include?(HandlesCustomDomains::InstanceMethods)
      include HandlesCustomDomains::InstanceMethods
    end
  end

  module InstanceMethods
  end
end

require 'handles_custom_domains/railtie'
