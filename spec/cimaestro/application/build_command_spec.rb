require "spec_helper"

module CIMaestro
  module Application
    describe BuilderCommand do

      DEFAULT_OPTIONS =  ['-S', 'CIMaestro', '-c', 'Mainline', '-n','1.0.0.0']

      it "should require the system name, codeline name and version" do
        Kernel.should_receive(:system).with("rake SYSTEM=CIMaestro CODELINE=Mainline VERSION=1.0.0.0 TRIGGER=forced default")
        BuilderCommand.new.run(['-S', 'CIMaestro', '-c', 'Mainline', '-n','1.0.0.0'])
      end

      it "should execute the given rake task" do
        Kernel.should_receive(:system).with(/.+\spurge/)
        BuilderCommand.new.run(DEFAULT_OPTIONS + ['-T', 'purge'])
      end

      it "should set the specified trigger" do
        Kernel.should_receive(:system).with(/.+\sTRIGGER=interval\s/)
        BuilderCommand.new.run(DEFAULT_OPTIONS + ['-t', 'interval'])
      end

      it "should enable trace" do
        Kernel.should_receive(:system).with(/.+\s--trace/)
        BuilderCommand.new.run(DEFAULT_OPTIONS + ['--trace'])
      end

      it "should set the base path" do
        Kernel.should_receive(:system).with(/.+\sBASE_PATH=c:\//)
        BuilderCommand.new.run(DEFAULT_OPTIONS + ['-p', 'c:/'])
      end

      it "should set the directory structure" do
        Kernel.should_receive(:system).with(/.+\sDIRECTORY_STRUCTURE=Directory/)
        BuilderCommand.new.run(DEFAULT_OPTIONS + ['-d', 'Directory'])
      end
    end
  end
end
