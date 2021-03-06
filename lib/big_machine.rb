require "active_support/all"
require "forwardable"
require "big_machine/state"
require "big_machine/active_record"
require "big_machine/available_methods"
require "big_machine/lock"

module BigMachine
  extend ActiveSupport::Concern

  included do
    class_attribute :initial_state
    class_attribute :workflow

    if active_record_model?
      include BigMachine::ActiveRecord
    end
  end

  module ClassMethods
    def active_record_model?
      defined?(::ActiveRecord::Base) && self.ancestors.include?(::ActiveRecord::Base)
    end

    def big_machine(options)
      self.initial_state   = options[:initial_state]
      self.workflow        = options[:workflow]
      set_initial_state_class
    end

    def initial_state_class
      @initial_state_class
    end

    def set_initial_state_class
      @initial_state_class = self.initial_state.to_s.camelize.constantize
      include ::BigMachine::AvailableMethods
    end
  end

  def current_state
    set_current_state(self.class.initial_state_class) unless @current_state

    @current_state
  end

  def set_current_state(new_state_class)
    @current_state = new_state_class.new self

    forward_current_state
  end

  def forward_current_state
    extend SingleForwardable
    def_delegators :current_state, *current_state.class.available_methods
  end

  def transition_to(next_state_class, *args, &block)
    return unless current_state.exit *args

    previous_state = current_state
    set_current_state next_state_class

    rollback(previous_state) and return unless current_state.enter *args

    block.call self if block_given?
  end

  def rollback(previous_state)
    @current_state = @previous_state
  end

end
