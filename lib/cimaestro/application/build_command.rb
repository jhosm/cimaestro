module CIMaestro
  module Application
    class BuilderCommand
      include CommandLineParser, CommandLineOptions

      def run(args)
        options = parse(args, BUILD_OPTIONS.merge(CONFIGURATION_OPTIONS))

        FileUtils.cd(CIMaestro::ROOT_PATH, :verbose => true) do
          cmd = "rake SYSTEM=#{options.system_name} CODELINE=#{options.codeline_name} VERSION=#{options.version_number} TRIGGER=#{options.trigger_type} "
          cmd += "BASE_PATH=#{options.base_path} " if options.base_path
          cmd += "DIRECTORY_STRUCTURE=#{options.directory_structure} " if options.directory_structure
          cmd += "--trace " if options.trace
          cmd += "#{options.task_name}"
          puts cmd
          Kernel.system(cmd)
        end
      end
    end
  end
end
