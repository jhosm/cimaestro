require "spec_helper"

module CIMaestro
  module Configuration

    describe BuildConfig do

      it "should give the correct defaults" do

        conf = BuildConfig.new

        conf.directory_structure.should == DefaultDirectoryStructure
        conf.base_path.should == ""
        conf.source_control.type.should == SourceControl::FileSystem
        conf.task_name.should == :default
        conf.trigger_type.should == :forced
        conf.version_number.to_s == "0.0.0.0"

      end

      it "should define the default directory path when the system and the codeline are defined and the default source control type is set" do

        conf = BuildConfig.new

        conf.system_name = "mySystem"
        conf.codeline_name = "Release"
        conf.base_path = "z:/"
        ds = conf.directory_structure.new(conf.base_path, conf.system_name, conf.codeline_name)
        conf.source_control.repository_path.should == ds.solution_dir_path
      end

      it "should merge two instances, with the merging instance only replacing the values not set" do
        system_build_conf = BuildConfig.new
        global_build_conf = BuildConfig.new

        system_build_conf.system_name = "yourSystem"
        global_build_conf.system_name = "globaaallll"
        global_build_conf.base_path = "z:/"
        global_build_conf.source_control.repository_path = '\\wow'

        system_build_conf.merge!(global_build_conf)
        system_build_conf.system_name.should == "yourSystem"
        system_build_conf.base_path.should == "z:/"
        system_build_conf.source_control.repository_path.should == '\\wow'
      end

      it "should be able to save and load a global configuration, used by all systems" do
        clean_config = BuildConfig.clear
        clean_config.base_path.should == ""

        global_build_conf = BuildConfig.new

        global_build_conf.base_path = "z:/"
        global_build_conf.source_control.repository_path = '\\wow'

        global_build_conf.save

        loaded_config = BuildConfig.load
        loaded_config.base_path.should == "z:/"
        loaded_config.source_control.repository_path = '\\wow'
      end

      it "should save a system specific configuration" do
        conf = BuildConfig.new

        conf.system_name = "aSystem"
        conf.codeline_name = "Mainline"
        conf.source_control.repository_path = '\\yabadabadoo'
        conf.base_path = TESTS_BASE_PATH

        conf.save

        loaded_conf = BuildConfig.load("aSystem", "Mainline", TESTS_BASE_PATH)
        loaded_conf.source_control.repository_path.should == '\\yabadabadoo'
      end
    end
  end
end