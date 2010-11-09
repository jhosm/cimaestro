module CIMaestro
  module Application
    class InstallCommand < CommandLineCommand

      def desc
        "Installs CIMaestro."
      end

      def run(args)
        FileUtils.cd(CIMaestro::ROOT_PATH, :verbose => true) do |dir|
          cmd = "bundle install --deployment --without development"
          puts cmd
          Kernel.system(cmd)
        end
      end
    end
  end
end
