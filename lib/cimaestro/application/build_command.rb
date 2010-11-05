require 'cimaestro/configuration/build_config'
require 'cimaestro/configuration/invalid_build_spec_exception'
include CIMaestro::Exceptions

module CIMaestro
  module Application
    include Exceptions

    class BuildCommand < CommandLineCommand
      include Configuration


      def desc
        "Builds a system."
      end

      def parse_args(args)
        parse(args, BUILD_OPTIONS.merge(CONFIGURATION_OPTIONS))
      end

      def configure_build(options)
        Rake.application.options.trace = options.trace if options.trace

        if options.system_name.blank? then
          raise InvalidBuildSpecException, <<HERE

    The SYSTEM_NAME was not specified, so I don't know what system to build.
    Check the help for the build command for directions on how to provide it.
HERE
        end
        global_config = BuildConfig.load()
        [:system_name, :codeline_name, :base_path, :directory_structure].each do |item|
          global_config.send(item.to_s + "=", options.send(item)) if options.send(item)
        end

        $build_config = BuildConfig.load(global_config.system_name, global_config.codeline_name, global_config.base_path)
        $build_config.merge!(global_config)

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
