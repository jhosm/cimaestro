require "spec_helper"
require 'json'

describe "OpenStructJson" do

  it "should serialize and deserialize an OpenStruct into JSON" do
    original = OpenStruct.new({ 'a' => 1, 'b' => true })
    original_hydrated =                  JSON.parse(JSON.generate(original))
    original_hydrated.kind_of?(OpenStruct).should be_true
    original_hydrated.a.should == original.a
    original_hydrated.b.should == original.b
  end
end