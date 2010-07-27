require "spec_helper"

describe PurgeTask do
  before(:each) do
    @build_spec = BuildSpec.new("Dummy_cimaestro", "Release", "4.5.8.7")
    @build_spec.base_path = TESTS_BASE_PATH
    @purge = PurgeTask.new :purge, @build_spec, NullLogger.new
  end

  it "should not fail if working directory does not exist" do
    lambda { @purge.execute }.should_not raise_error
  end
end