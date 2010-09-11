module CIMaestro
  module Application
    class ConfiguratorCommand
       include CommandLineParser, CommandLineOptions

       def run(args)
        options = parse(args, CONFIGURATION_OPTIONS)
        config = AppConfig.load
        config.base_path = options.base_path if options.base_path
        config.directory_structure = options.directory_structure if options.directory_structure
        config.save
      end
    end
  end
end