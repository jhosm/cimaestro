require "spec_helper"
require "cimaestro/configuration/build_config"

module CIMaestro
  module Application
    include ::CIMaestro::Configuration

    class TestDirectoryStructure < DefaultDirectoryStructure;end

    describe ConfigCommand do

      before :each do
        BuildConfig.clear
      end

      it "should set the base path" do
        ConfigCommand.new.run(['-p', 'c:/'])
        config = BuildConfig.load()
        config.base_path.should == "c:/"
      end

      it "should set the directory structure" do
        ConfigCommand.new.run(['-d', 'CIMaestro::Application::TestDirectoryStructure'])
        config = BuildConfig.load()
        config.directory_structure.should == TestDirectoryStructure
      end

      it "should set the source control system" do
        ConfigCommand.new.run(['--sc_type', 'CIMaestro::SourceControl::Svn'])
        config = BuildConfig.load()
        config.source_control.system_proxy.should == CIMaestro::SourceControl::Svn
      end
    end
  end
end

