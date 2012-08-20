module BigMachine
  module AvailableMethods
    extend Forwardable

    def self.included(base)
      def_delegators :current_state, *base.initial_state_class.available_methods
    end
  end
end