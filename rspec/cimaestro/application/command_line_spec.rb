require "rspec/spec_helper"

module CIMaestro
  module Application

    class DummyCommand < CommandLineCommand
      @@args = []
      class << self
        def received_args
          @@args
        end
      end
      def run(args)
        @@args = args
        0
      end
    end

    class YummyDummyCommand < CommandLineCommand; def run(args); end; end
    class NoRunCommand ;end

    describe CommandLine do
      it "should choose the correct command to run" do
        CommandLine.select_command(["dummy", "--anoption xpto"]).should be_instance_of(DummyCommand)
        CommandLine.select_command(["yummy_dummy", "--anoption xpto"]).should be_instance_of(YummyDummyCommand)
      end

      it "should choose the correct default command whn none is given" do
        CommandLine.select_command(["--anoption xpto"]).should be_instance_of(BuildCommand)
      end

      it "should raise when the command is unknown or does not respond to a 'run' message" do
        lambda {CommandLine.select_command(["unknown"])}.should raise_error(UnknownApplicationCommandException, "Command 'unknown' is not supported.")
        lambda {CommandLine.select_command(["no_run"])}.should raise_error(UnknownApplicationCommandException, "The class that should execute command 'no_run' is not a subclass of CommandLineCommand.")
      end

      it "should execute the command, passing only the arguments to the command, and return the return value of the command" do
        CommandLine.run(["dummy", "--anoption"]).should == 0
        DummyCommand.received_args.should =~ ["--anoption"]
      end
    end
  end
end