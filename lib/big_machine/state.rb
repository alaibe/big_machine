module BigMachine
  class State

    attr_reader :stateful
    
    def initialize(stateful)
      @stateful = stateful
      enter
    end

    def self.transition_methods
      public_instance_methods - State.public_instance_methods
    end

    def transition_to(state_class)
      @stateful.transition_to(state_class)
    end

    def workflow_is(name)
      @stateful.workflow == name
    end

    def enter
    end

    def exit
    end
  end
end