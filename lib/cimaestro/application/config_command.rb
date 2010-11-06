require 'cimaestro/configuration/build_config'

module CIMaestro
  module Application
    class ConfigCommand < CommandLineCommand
      include Configuration

      def desc
        "Defines global configurations."
      end

      def run(args)
        options = parse(args, BUILD_OPTIONS)
        config = BuildConfig.load
        config.merge!(options, :override=>true)

        config.save
        y BuildConfig.load
      end
    end
  end
end