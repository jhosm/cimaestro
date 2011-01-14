require 'cimaestro/configuration/build_config'
require 'cimaestro/configuration/invalid_build_spec_exception'

module CIMaestro
  module Application
    include Exceptions

    class RuoteBuildCommand < CommandLineCommand
      include Configuration

      def desc
        "Builds a system."
      end

      def parse_args(args)
        parse(args, BUILD_OPTIONS)
      end

      def run(args)
        build_args = parse_args(args)
        workitem = {'build_config' => BuildConfig.new(build_args.system_name, build_args.codeline_name, build_args.base_path).to_ostruct}

        ProcessLauncher.new.launch(build_process_definition(), workitem)
      end

      def build_process_definition
        return ::Ruote.process_definition do
          noopx
        end
      end
    end
  end
end
