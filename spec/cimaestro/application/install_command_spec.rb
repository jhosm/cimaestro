require "spec_helper"

module CIMaestro
  module Application
    describe InstallCommand do
      it "should do the setup on the CIMaestro root dir" do
        FileUtils.should_receive(:cd).with(CIMaestro::ROOT_PATH, :verbose => true)
        Kernel.stub!(:system)
        InstallCommand.new.run([])
      end

      it "should execute bundle install without gem home specified when none is given" do
        Kernel.should_receive(:system).with("bundle install  --without development")
        InstallCommand.new.run([])
      end

      it "should execute bundle install with the given gem_home option" do
        Kernel.should_receive(:system).with("bundle install c:/ --without development")
        InstallCommand.new.run(["--gem_home", "c:/"])

        Kernel.should_receive(:system).with("bundle install D:/ --without development")
        InstallCommand.new.run(["-g", "D:/"])
      end
    end
  end
end
