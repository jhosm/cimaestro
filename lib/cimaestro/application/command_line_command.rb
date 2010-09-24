module CIMaestro
  module Application
    class CommandLineCommand
      include CommandLineParser, CommandLineOptions
      def desc
        raise NotImplementedError.new("You must implement desc.")
      end

      def run(args)
        raise NotImplementedError.new("You must implement run(args).") 
      end
    end
  end
end
