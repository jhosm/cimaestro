module CIMaestro
  module Application
    class ConfigCommand < CommandLineCommand

      def desc
        "Defines global configurations."
      end

      def run(args)
        options = parse(args, CONFIGURATION_OPTIONS)
        config = BuildConfig.load
        config.base_path = options.base_path if options.base_path
        config.directory_structure = options.directory_structure if options.directory_structure
        config.save
        y BuildConfig.load
      end
    end
  end
end