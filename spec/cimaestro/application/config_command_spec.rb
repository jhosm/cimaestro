require "spec_helper"

module CIMaestro
  module Application

    class TestDirectoryStructure < DefaultDirectoryStructure;end

    describe ConfiguratorCommand do

      before :each do
        AppConfig.clear
      end

      it "should set the base path" do
        ConfiguratorCommand.new.run(['-p', 'c:/'])
        config = AppConfig.load
        config.base_path.should == "c:/"
      end

      it "should set the directory structure" do
        ConfiguratorCommand.new.run(['-d', 'CIMaestro::Application::TestDirectoryStructure'])
        config = AppConfig.load
        config.directory_structure.should == TestDirectoryStructure
      end
    end
  end
end

