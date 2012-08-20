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
      attribute = send state_attribute
      if attribute
        set_current_state(attribute.constantize)
      else
        self.class.set_initial_state_class
      end
    end

    def set_current_state(new_state_class)
      super(new_state_class)
      send "#{state_attribute}=", new_state_class.name
    end

    def transition_to(next_state_class)
      super(next_state_class)
      save!
    end
  end
end
