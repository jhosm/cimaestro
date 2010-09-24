require "spec_helper"

module CIMaestro
  module Configuration

    describe BuildConfig do

      it "should give the correct defaults" do

        BuildConfig.clear
        conf = BuildConfig.load

        conf.directory_structure.should == DefaultDirectoryStructure
        conf.base_path.should == ""
        conf.source_control.type.should == SourceControl::FileSystem
        conf.task_name.should == :default
        conf.trigger_type.should == :forced
        conf.version_number.to_s == "0.0.0.0"

      end

      it "should define the default directory path when the system and the codeline are defined and the default source control type is set" do

        BuildConfig.clear
        conf = BuildConfig.load

        conf.system_name = "mySystem"
        conf.codeline_name = "Release"
        ds = conf.directory_structure.new(conf.base_path, conf.system_name, conf.codeline_name)
        conf.source_control.repository_path == ds.solution_dir_path 
      end
    end
  end
end