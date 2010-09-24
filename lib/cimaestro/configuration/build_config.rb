require 'yaml'

module CIMaestro
  module Configuration
    class BuildConfig
      
      GLOBAL_CONFIG_PATH = File.join(CIMaestro::ROOT_PATH, "config.yaml")

      class << self
        def load
          result = nil

          if File.exist?(GLOBAL_CONFIG_PATH) then
            File.open(GLOBAL_CONFIG_PATH, "r") do |file|
              result = YAML::load(file)
            end
          end

          result ||= BuildConfig.new
          result
        end

        def clear
          File.delete(GLOBAL_CONFIG_PATH) if File.exist?(GLOBAL_CONFIG_PATH)
          load
        end
      end

      attr_reader :source_control, :system_name, :codeline_name

      def initialize
        @source_control = SourceControl.new
      end

      def save
        File.open(GLOBAL_CONFIG_PATH, "w+") do |file|
          YAML::dump(self, file)
        end
      end

      def set_default_repository_path
        if @system_name != nil and not @system_name.empty? and
                @codeline_name != nil and not @codeline_name.empty? and
                @base_path != nil and not @base_path.empty? and
                @source_control.is_using_default_type? and
                not @source_control.has_repository_path? then
          ds = directory_structure.new(base_path, system_name, codeline_name)
          @source_control.repository_path = ds.solution_dir_path
        end
      end

      def system_name=(value)
        @system_name = value

        set_default_repository_path()
      end

      def codeline_name=(value)
        @codeline_name = value
        set_default_repository_path()
      end

      def version_number
        @version_number ||= BuildVersion.new("0.0.0.0")
      end

      def version_number=(value)
        if value === String then
          @version_number = BuildVersion.new(value) 
        else
          @version_number = value
        end
      end

      def task_name
        @task_name ||= :default
      end

      def task_name=(value)
        @task_name = value
      end

      def trigger_type
        @trigger_type ||= :forced
      end

      def trigger_type=(value)
        @trigger_type = value
      end

      def base_path
        @base_path ||= ""
      end

      def base_path=(value)
        @base_path = value
        set_default_repository_path()
      end

      def directory_structure
        @directory_structure ||= DefaultDirectoryStructure
      end

      def directory_structure=(value)
        @directory_structure = value.to_class
      end

    end
  end
end

