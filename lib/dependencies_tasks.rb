require "required_references"

module Build

  class UpdateDependenciesTask < Task

    attr_reader :solutions

    def initialize(rake_name, build_spec, logger)
      super(rake_name, build_spec, logger)
    end

    def setup
      @dependencies_files = build_spec.get_spec_for(
              rake_name,
                      :dependencies_files,
                      FileList[])
    end

    def execute
      mkpath build_spec.lib_dir_path
      @dependencies_files.each do |file|
        cp_r file, build_spec.lib_dir_path
      end
    end
  end
end