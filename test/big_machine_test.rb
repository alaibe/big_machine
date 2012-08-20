require 'test_helper'

class Draft < BigMachine::State
  def publish
    return if workflow_is :small

    transition_to Online
  end

  def lock
    transition_to LockState
  end
end

class LockState < BigMachine::State
  include BigMachine::Lock

  def back_to_draft
    transition_to Draft
  end
end

class Online < BigMachine::State
  def back_to_draft
    transition_to Draft
  end
end

class DummyMachine
  include BigMachine

  big_machine initial_state: :draft
end

class DummyWithWorkflow
  include BigMachine

  big_machine initial_state: :draft, workflow: :small
end

class DummyWithActiveRecord < ActiveRecord::Base
  include BigMachine

  attr_accessor :state

  big_machine initial_state: :draft

  def initialize(state)
    @state = state
  end

  def state
    @state
  end
end

class DummyWithActiveRecordAndOtherState < ActiveRecord::Base
  include BigMachine

  attr_accessor :other_state

  big_machine initial_state: :draft, state_attribute: :other_state

  def other_state
    'Online'
  end
end

class BigMachineTest < ActiveSupport::TestCase
  setup do
    @dummy   = DummyMachine.new
    @dummyAR = DummyWithActiveRecord.new('Online')
  end

  test "big_machine set initial state" do
    assert_equal 'Draft', @dummy.current_state.class.name
  end

  test "big_machine create new state when start transition" do
    @dummy.publish
    assert_equal 'Online', @dummy.current_state.class.name
    @dummy.back_to_draft
    assert_equal 'Draft', @dummy.current_state.class.name
  end

  test "big machine must refuse unavailable action" do
    @dummy.publish
    assert_raise NoMethodError do
      @dummy.publish
    end
  end

  test "big machine can lock state" do
    @dummy.lock
    assert @dummy.locked?
    @dummy.back_to_draft
    assert_equal 'LockState', @dummy.current_state.class.name
    assert @dummy.current_state.locked?
    @dummy.unlock
    assert !@dummy.current_state.locked?
    assert_equal 'LockState', @dummy.current_state.class.name
    @dummy.back_to_draft
    assert_equal 'Draft', @dummy.current_state.class.name
  end

  test "big_machine can have workflow to refuse some action" do
    @dummyW = DummyWithWorkflow.new
    @dummyW.publish
    assert_equal 'Draft', @dummyW.current_state.class.name
  end

  test "big_machine read state from database" do
    assert_equal 'Online', @dummyAR.current_state.class.name
  end

  test "big_machine read state from specify column in database" do
    @dummyAROS = DummyWithActiveRecordAndOtherState.new
    assert_equal 'Online', @dummyAROS.current_state.class.name
  end

  test "big_machine must update attribute when state change" do
    @dummyAR.back_to_draft
    assert_equal 'Draft', @dummyAR.current_state.class.name
    assert_equal 'Draft', @dummyAR.state
  end

  test "big_machine must set initial state even if active record object" do
    @dummyWS = DummyWithActiveRecord.new(nil)
    assert_equal 'Draft', @dummyWS.current_state.class.name
  end
end
