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

        klass = self
        ghost = class << self; self end
        ghost.class_eval do
          define_method(:find_matching_domain_for) do |request|
            self.find_by_domain_name(request.server_name)
          end
        end

        activerecord_ghost = class << ActiveRecord::Base; self end
        activerecord_ghost.class_eval do
          original_table_name_prefix = instance_method(:table_name_prefix)
          define_method(:table_name_prefix) do |*args|
            return Thread.current[:selected_dataset].name_prefix unless self.name == klass.name
            original = original_table_name_prefix.bind(self)
            original.call(*args)
          end
        end

        # actioncontroller_ghost = class << ActiveController::Base; self end
        # ActiveController::Base.before_filter do
        #   Thread.current[:stored_request] = request
        # end
      end
    end

    module InstanceMethods
      def select_as_dataset
        Thread.current[:selected_dataset] = self
      end
    end
  end
end

require 'handles_custom_domains/railtie'
