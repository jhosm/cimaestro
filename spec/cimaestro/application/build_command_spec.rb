require "spec/spec_helper"

module CIMaestro
  module Application

    class TestDirectoryStructure < DefaultDirectoryStructure;end

    describe BuildCommand do

      DEFAULT_OPTIONS =  ['-S', 'CIMaestro', '-c', 'Mainline', '-n','1.0.0.0']


      it "should require the system name, codeline name and version" do
        lambda {BuildCommand.new.parse_args(['-S', 'CIMaestro', '-c', 'Mainline', '-n','1.0.0.0'])}.should_not raise_exception()
      end

      it "should execute the given rake task" do
        mocked_task = mock("task").as_null_object

        Rake.application.should_receive(:[]).with("purge").and_return(mocked_task)
        BuildCommand.new.run(DEFAULT_OPTIONS + ['-T', 'purge'])
      end

      it "should set the specified trigger" do
        BuildCommand.new.prepare_build(DEFAULT_OPTIONS + ['-t', 'interval'])
        $build_config.trigger_type.should == 'interval'
      end

      it "should enable trace" do
        BuildCommand.new.prepare_build(DEFAULT_OPTIONS + ['--trace'])
        Rake.application.options.trace.should be_true
      end

      it "should set the base path" do
        BuildCommand.new.prepare_build(DEFAULT_OPTIONS + ['-p', 'c:/'])
        $build_config.base_path.should == 'c:/'
      end

      it "should set the directory structure" do
        BuildCommand.new.prepare_build(DEFAULT_OPTIONS + ['-d', 'CIMaestro::Application::TestDirectoryStructure'])
        $build_config.directory_structure.should == TestDirectoryStructure
      end

       it "should use the global config" do
        global = BuildConfig.new
        global.source_control.repository_path = "Z:/"

        BuildConfig.should_receive(:load).and_return(global, BuildConfig.new)

        BuildCommand.new.prepare_build(DEFAULT_OPTIONS.dup)

        $build_config.source_control.repository_path.should == "Z:/"
      end

      it "should give higher priority to the system config than to the global config" do
        global = BuildConfig.new
        global.source_control.repository_path = "Z:/"

        system_conf = BuildConfig.new
        system_conf.source_control.repository_path = "C:/"

        BuildConfig.should_receive(:load).and_return(global, system_conf)

        BuildCommand.new.prepare_build(DEFAULT_OPTIONS.dup)

        $build_config.source_control.repository_path.should == "C:/"
      end

      it "should give higher priority to an option passed as parameter than to the system config " do

        system_conf = BuildConfig.new
        system_conf.base_path = "G:/"
        BuildConfig.should_receive(:load).and_return(BuildConfig.new, system_conf)

        BuildCommand.new.prepare_build(DEFAULT_OPTIONS + ['-p', 'c:/'])

        $build_config.base_path.should == "c:/"
      end
    end
  end
end
