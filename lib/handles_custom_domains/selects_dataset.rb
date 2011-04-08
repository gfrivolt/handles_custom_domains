require 'active_record'

module HandlesCustomDomains

  module SelectsDataset
    def self.included(base)
      base.extend ClassMethods
    end

    def self.current_dataset
      Thread.current[:selected_dataset]
    end

    def self.current_dataset=(dataset)
      Thread.current[:selected_dataset] = dataset
    end

    def self.clear_current_dataset!
      Thread.current[:selected_dataset] = nil
    end

    module ClassMethods
      def selects_dataset(options = {})
        return if self.included_modules.include?(SelectsDataset::InstanceMethods)
        HandlesCustomDomains.was_called_on = self
        include SelectsDataset::InstanceMethods

        klass = self
        ghost = class << self; self end
        ghost.class_eval do
          define_method(:find_matching_domain_for) do |request|
            self.find_by_domain_name(request.server_name)
          end

          define_method(:clear_dataset_selection!) { SelectsDataset.clear_current_dataset! }
        end

        activerecord_ghost = class << ActiveRecord::Base; self end
        activerecord_ghost.class_eval do
          original_table_name_prefix = instance_method(:table_name_prefix)
          define_method(:table_name_prefix) do |*args|
            return SelectsDataset.current_dataset.name_prefix unless (self.name == klass.name) || !SelectsDataset.current_dataset
            original = original_table_name_prefix.bind(self)
            original.call(*args)
          end
        end
      end
    end

    module SharedMethods

      class << self
        attr_accessor :cached_attr

        CACHED_CLASS_VARIABLES = [:column_names, :columns, :columns_hash, :content_columns, :dynamic_methods_hash,
                                  :inheritance_column, :arel_engine, :relation, :arel_table, :table_name, :quoted_table_name]

        def cache_state_for(klass)
          current_dataset = SelectsDataset.current_dataset
          klass_cached_attr = cached_attr[klass][current_dataset]
          CACHED_CLASS_VARIABLES.each do |var_name|
            klass_cached_attr[var_name] = klass.instance_variable_get("@#{var_name}")
          end
        end

        def restore_state_for(klass)
          current_dataset = SelectsDataset.current_dataset
          klass_cached_attr = cached_attr[klass][current_dataset]
          if klass_cached_attr.empty?
            klass.reset_table_name
            klass.reset_column_information
          else
            CACHED_CLASS_VARIABLES.each do |var_name|
              klass.instance_variable_set("@#{var_name}", klass_cached_attr[var_name])
            end
          end
        end

        def clear_cache
          self.cached_attr = Hash.new do |klass_hash, klass|
            klass_hash[klass] = Hash.new do |dataset_hash, dataset|
              dataset_hash[dataset] = {}
            end
          end
        end
      end

      self.clear_cache
    end

    module InstanceMethods
      def select_as_dataset
        unless SelectsDataset.current_dataset == self
          current_dataset = SelectsDataset.current_dataset
          selected_dataset = self
          ActiveRecord::Base.descendants.each do |klass|
            unless klass <= HandlesCustomDomains.was_called_on
              SharedMethods.cache_state_for(klass)
              SelectsDataset.current_dataset = selected_dataset
              SharedMethods.restore_state_for(klass)
            end
          end
        end
      end
    end
  end
end

require 'handles_custom_domains/railtie'
