require "spec_helper"

describe GetSourcesTask do

  class NullSourceControl
    @@checkedout = false

    def checkout
      @@checkedout = true
    end
    def checkedout
      @@checkedout
    end
  end

  class NullSourceControlBuildSpec < CIMaestro::Configuration::BuildSpec
    def initialize; end
    def src_control
      NullSourceControl.new
    end
  end

  it "should checkout" do
    build_spec =  NullSourceControlBuildSpec.new
    task = GetSourcesTask.new :sym, build_spec, nil
    task.execute

    build_spec.src_control.checkedout.should be_true
  end
end
