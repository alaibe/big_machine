require 'test_helper'

class Draft < BigMachine::State
  def publish
    return if workflow_is :small

    transition_to Online
  end

  def cannot_enter
    transition_to CannotEnter
  end

  def lock
    transition_to LockState
  end
end

class Args < BigMachine::State

  def publish
    transition_to Online, 'args'
  end

  def back_to_draft
    transition_to Online do |obj|
      obj.block = 'block'
    end
  end

  def exit(*args)
    @stateful.args = args.first
    super
  end
end

class CannotExit < BigMachine::State

  def publish
    transition_to Online
  end

  def exit
    false
  end
end

class CannotEnter < BigMachine::State
  def enter
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

  attr_accessor :state, :args, :block

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

class BigMachineTest < Test::Unit::TestCase
  def setup
    @dummy   = DummyMachine.new
    @dummyAR = DummyWithActiveRecord.new('Online')
  end

  def test_big_machine_set_initial_state
    assert_equal 'Draft', @dummy.current_state.class.name
  end

  def test_big_machine_create_new_state_when_start_transition
    @dummy.publish
    assert_equal 'Online', @dummy.current_state.class.name
    @dummy.back_to_draft
    assert_equal 'Draft', @dummy.current_state.class.name
  end

  def test_big_machine_must_refuse_unavailable_action
    @dummy.publish
    assert_raise NoMethodError do
      @dummy.publish
    end
  end

  def test_big_machine_can_lock_state
    @dummy.lock
    assert @dummy.locked?
    @dummy.back_to_draft
    assert_equal 'LockState', @dummy.current_state.class.name
    assert @dummy.locked?
    @dummy.unlock
    assert !@dummy.locked?
    assert_equal 'LockState', @dummy.current_state.class.name
    @dummy.back_to_draft
    assert_equal 'Draft', @dummy.current_state.class.name
  end

  def test_big_machine_can_have_workflow_to_refuse_some_action
    @dummyW = DummyWithWorkflow.new
    @dummyW.publish
    assert_equal 'Draft', @dummyW.current_state.class.name
  end

  def test_big_machine_read_state_from_database
    assert_equal 'Online', @dummyAR.current_state.class.name
  end

  def test_big_machine_read_state_from_specify_column_in_database
    @dummyAROS = DummyWithActiveRecordAndOtherState.new
    assert_equal 'Online', @dummyAROS.current_state.class.name
  end

  def test_big_machine_must_update_attribute_when_state_change
    @dummyAR.back_to_draft
    assert_equal 'Draft', @dummyAR.current_state.class.name
    assert_equal 'Draft', @dummyAR.state
  end

  def test_big_machine_must_set_initial_state_even_if_active_record_object
    @dummyWS = DummyWithActiveRecord.new(nil)
    assert_equal 'Draft', @dummyWS.current_state.class.name
  end

  def test_big_machine_does_not_transtion_if_it_s_not_possible_to_exit
    @dummyCE = DummyWithActiveRecord.new('CannotExit')
    @dummyCE.publish
    assert_equal 'CannotExit', @dummyCE.current_state.class.name
  end

  def test_big_machine_does_not_transtion_if_it_s_not_possible_to_enter
    @dummyCE = DummyWithActiveRecord.new('Draft')
    @dummyCE.cannot_enter
    assert_equal 'Draft', @dummyCE.current_state.class.name
  end

  def test_big_machine_can_take_args_into_transition
    @dummyArgs = DummyWithActiveRecord.new('Args')
    @dummyArgs.publish
    assert_equal 'args', @dummyArgs.args
  end

  def test_big_machine_can_take_block_into_transition
    @dummyArgs = DummyWithActiveRecord.new('Args')
    @dummyArgs.back_to_draft
    assert_equal 'block', @dummyArgs.block
  end
end
