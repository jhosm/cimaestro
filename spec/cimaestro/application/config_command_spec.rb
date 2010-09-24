require "spec_helper"

module CIMaestro
  module Application

    class TestDirectoryStructure < DefaultDirectoryStructure;end

    describe ConfigCommand do

      before :each do
        BuildConfig.clear
      end

      it "should set the base path" do
        ConfigCommand.new.run(['-p', 'c:/'])
        config = BuildConfig.load
        config.base_path.should == "c:/"
      end

      it "should set the directory structure" do
        ConfigCommand.new.run(['-d', 'CIMaestro::Application::TestDirectoryStructure'])
        config = BuildConfig.load
        config.directory_structure.should == TestDirectoryStructure
      end
    end
  end
end

