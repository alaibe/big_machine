module BigMachine
  module Lock
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def transition_methods
        public_instance_methods - State.public_instance_methods - [:unlock, :locked?]
      end

      def available_methods
        public_instance_methods - State.public_instance_methods
      end
    end

    def locked?
      @locked
    end

    def enter(*args)
      @locked = true
    end

    def unlock(*args)
      @locked = false
    end

    def transition_to(state_class, *args, &block)
      return if @locked

      super(state_class, *args, &block)
    end
  end
end
