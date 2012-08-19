module BigMachine
  module Lock
    extend ActiveSupport::Concern

    included do
    end

    def locked?
      @locked
    end

    def enter
      @locked = true
    end

    def unlock
      @locked = false
    end

    def transition_to(state_class)
      return if @locked

      super
    end
  end
end