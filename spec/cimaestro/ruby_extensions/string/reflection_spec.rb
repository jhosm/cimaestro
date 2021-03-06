require "spec/spec_helper"

CIMAESTROCONST = 1

describe "StringReflection" do

  it "should find class or module constant" do
    "String".to_class.should == ::String
    "CIMaestro::Configuration::BuildSpec".to_class.should == BuildSpec
  end


  it "should give a meaningful error message when string is not a class" do
    lambda { "_yoda".to_class }.should raise_error(NameError)
    lambda { "CIMAESTROCONST".to_class }.should raise_error(NameError, "The string translates to a Constant which is not a Class.")
  end
end
