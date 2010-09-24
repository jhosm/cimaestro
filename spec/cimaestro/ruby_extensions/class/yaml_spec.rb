require "spec_helper"

describe "ClassYaml" do

  it "should serialize and deserialize a Class into Yaml" do
    YAML::load(String.to_yaml).should == String
  end
end