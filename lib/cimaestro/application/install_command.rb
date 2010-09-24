module CIMaestro
  module Application
    class InstallCommand < CommandLineCommand

      def desc
        "Installs CIMaestro."
      end

      def run(args)
        options = parse(args, INSTALLER_OPTIONS) 

        FileUtils.cd(CIMaestro::ROOT_PATH, :verbose => true) do |dir|
          cmd = "bundle install #{options.gem_home} --without development"
          puts cmd
          Kernel.system(cmd)
        end
      end
    end
  end
end
