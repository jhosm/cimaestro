require "spec/spec_helper"

describe PurgeTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "Dummy_cimaestro", "Release", "4.5.8.7")
    @purge = PurgeTask.new :purge, @build_spec, NullLogger.new
  end

  it "should not fail if working directory does not exist" do
    lambda { @purge.execute }.should_not raise_error
  end
end