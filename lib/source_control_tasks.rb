require "required_references"
module Build
  class GetSvnSourcesTask < Task
    include Build::ShellUtils

    attr_reader :src_control

    def initialize(rake_name, build_spec, logger)
      super(rake_name, build_spec, logger)
      @src_control = SourceControlFactory.create(build_spec.working_dir_path, build_spec.source_control_repository_path+"/"+Build::SOLUTION_DIR)
    end

    def execute
      @src_control.checkout
    end
  end

  class GetLocalSourcesTask < Task
    include Build::ShellUtils

    def execute
      logger.log_msg "If '#{build_spec.solution_dir_path}' exists, copy it to '#{build_spec.working_dir_path}'."
      exec_and_log("attrib -R #{File.join(build_spec.working_dir_path, "*.*")} /S")
      FileUtils.cp_r(File.join(build_spec.solution_dir_path, "."), build_spec.working_dir_path) if File.exist?(build_spec.solution_dir_path)
    end
  end
end