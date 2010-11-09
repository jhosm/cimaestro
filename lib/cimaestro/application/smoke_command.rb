require 'cimaestro/configuration/build_config'

module CIMaestro
  module Application

    class SmokeCommand < CommandLineCommand
      include Configuration

      def desc
        "Runs a smoke test: tries to build the Simple sample."
      end

      def configure_build()
        Rake.application.options.trace = true

        global_config = BuildConfig.load()
        global_config.base_path = File.join(File.dirname(__FILE__), "..","..", "..","samples","defaultdirectorystructure")

        $build_config = BuildConfig.load("Simple", "Release", global_config.base_path)
        $build_config.merge!(global_config)
        $build_config.source_control.repository_path  = File.join(File.dirname(__FILE__), "..","..", "..","samples","defaultdirectorystructure", "Simple", "Release", "Solution")
      end

      def run(args)
        configure_build()

        FileUtils.cd(CIMaestro::ROOT_PATH, :verbose => true) do
          Rake.application.rake_require 'cimaestro'
          Rake.application[$build_config.task_name].invoke
        end
      end
    end
  end
end
