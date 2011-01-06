require "spec_helper"
require 'json'

describe "ClassJson" do

  it "should serialize and deserialize a Class into JSON" do
    JSON.parse(JSON.generate(OpenStruct)).should == OpenStruct
  end
end