require "spec/spec_helper"

module CIMaestro
  module Application
    describe InstallCommand do
      it "should do the setup on the CIMaestro root dir" do
        FileUtils.should_receive(:cd).with(CIMaestro::ROOT_PATH, :verbose => true)
        Kernel.stub!(:system)
        InstallCommand.new.run([])
      end

      it "should execute bundle install without gem home specified when none is given" do
        Kernel.should_receive(:system).with("bundle install --deployment --without development")
        InstallCommand.new.run([])
      end
    end
  end
end
