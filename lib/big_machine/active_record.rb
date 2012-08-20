module BigMachine
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      class_attribute :state_attribute
      after_initialize :set_current_state_from_db
    end

    module ClassMethods
      def big_machine(options = {})
        super options
        self.state_attribute = options[:state_attribute] || 'state'
      end
    end

    def set_current_state_from_db
      return unless self.class.initial_state_class

      attribute = send state_attribute

      state_class = attribute ? attribute.constantize : self.class.initial_state_class
      set_current_state(state_class)
    end

    def set_current_state(new_state_class)
      super(new_state_class)
      send "#{state_attribute}=", new_state_class.name
    end

  end
end
