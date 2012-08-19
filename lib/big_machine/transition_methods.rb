module BigMachine
  module TransitionMethods
    extend Forwardable

    def self.included(base)
      def_delegators :current_state, *base.initial_state_class.transition_methods
    end
  end
end