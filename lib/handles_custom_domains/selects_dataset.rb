require 'active_record'

module HandlesCustomDomains
  module SelectsDataset
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def selects_dataset(options = {})
        return if self.included_modules.include?(HandlesCustomDomains::SelectsDataset::InstanceMethods)
        include HandlesCustomDomains::SelectsDataset::InstanceMethods

        ghost = class << self; self end
        ghost.class_eval do
          define_method(:find_matching_domain_for) do |request|
            self.find_by_domain_name(request.server_name)
          end
        end
      end
    end

    module InstanceMethods
    end
  end
end

require 'handles_custom_domains/railtie'
