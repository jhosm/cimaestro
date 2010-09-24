module CIMaestro
  module Configuration
    class DefaultDirectoryStructure

      def working_dir
         "Integration"
      end
      def solution_dir
        "Solution"
      end
      def artifacts_dir
        "Artifacts"
      end
      def latest_artifacts_dir
        "Latest"
      end
      def cimaestro_dir
        "CIMaestro"
      end
      def lib_dir
        "Lib"
      end
      def logs_dir
        "Logs"
      end

      def initialize(base_path, system_name, codeline)
        ArgValidation.check_empty_string(system_name, :system_name)
        ArgValidation.check_empty_string(codeline, :codeline)

        @base_path = base_path
        @system_name = system_name
        @codeline = codeline
      end

      def system_base_path
        File.join(@base_path, @system_name, @codeline)
      end

      def working_dir_path
        File.join(system_base_path, working_dir)
      end

      def solution_dir_path
        File.join(system_base_path, solution_dir)
      end

      def latest_artifacts_dir_path
        File.join(system_base_path, artifacts_dir, latest_artifacts_dir)
      end

      def artifacts_dir_path(version="Latest")
        File.join(system_base_path, artifacts_dir, version)
      end

      def cimaestro_dir_path
        File.join(system_base_path, cimaestro_dir)
      end

      def lib_dir_path
        File.join(working_dir_path, lib_dir)
      end

      def logs_dir_path
        File.join(cimaestro_dir_path, logs_dir)
      end
    end
  end
end

