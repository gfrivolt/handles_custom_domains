require 'active_record'

module SelectsDataset
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def selects_dataset(options = {})

    end
  end

  module InstanceMethods
  end
end

require 'handles_custom_domains/railtie'
