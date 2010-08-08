require "spec_helper"

include Build

describe ExecutionTimeTask do

  class SleepTask < Task
    def initialize
    end

    def execute
      sleep 0.1
    end
  end

  it "should count time" do
    @execution_time = ExecutionTimeTask.new SleepTask.new, BuildSpec.new(TESTS_BASE_PATH, "x","x", "1.0.0.0")
    @execution_time.setup
    @execution_time.execute
    @execution_time.duration.should be_close(0.1, 0.1)
  end

  it "should count time, even if task throws" do
    task = mock("FailsTask", :null_object => true)
    task.should_receive(:execute).once.and_raise("erro")
    @execution_time = ExecutionTimeTask.new task, BuildSpec.new(TESTS_BASE_PATH, "x","x", "1.0.0.0")
    @execution_time.setup
    lambda { @execution_time.execute }.should raise_error
    @execution_time.duration.should be_close(0,0.01)
  end
end




