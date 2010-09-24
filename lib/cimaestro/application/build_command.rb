require 'cimaestro/configuration/build_config'

module CIMaestro
  module Application
    class BuildCommand < CommandLineCommand


      def desc
        "Builds a system."
      end

      def parse_args(args)
        parse(args, BUILD_OPTIONS.merge(CONFIGURATION_OPTIONS))
      end

      def configure_build(options)
        Rake.application.options.trace = options.trace if options.trace
        $build_config = BuildConfig.load

        [:system_name, :codeline_name, :trigger_type, :task_name, :base_path, :directory_structure].each do |item|
          $build_config.send(item.to_s + "=", options.send(item)) if options.send(item)
        end
      end

      def prepare_build(args)
        configure_build(parse_args(args))
      end

      def run(args)
        prepare_build(args)

        FileUtils.cd(CIMaestro::ROOT_PATH, :verbose => true) do
          Rake.application.rake_require 'cimaestro'
          Rake.application[$build_config.task_name].invoke
        end
      end
    end
  end
end
