module BigMachine
  class State

    attr_reader :stateful

    def initialize(stateful)
      @stateful = stateful
    end

    def self.transition_methods
      public_instance_methods - State.public_instance_methods
    end

    def transition_to(state_class, *args, &block)
      @stateful.transition_to(state_class, *args, &block)
    end

    def workflow_is(name)
      @stateful.workflow == name
    end

    def enter(*args, &block)
      true
    end

    def exit(*args, &block)
      true
    end
  end
end
