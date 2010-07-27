module Build

  class PurgeTask < Task
    def execute
      logger.log_msg "If '#{build_spec.working_dir_path}' exists, remove it."
      FileUtils.rm_r build_spec.working_dir_path if File.exist?(build_spec.working_dir_path)
      FileUtils.rm FileList[File.join(build_spec.logs_dir_path, "*-results.*")], :force=>true
      FileUtils.rm_r build_spec.latest_artifacts_dir_path if File.exist?(build_spec.latest_artifacts_dir_path)
    end
  end
end
