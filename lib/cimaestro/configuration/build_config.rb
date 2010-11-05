require 'active_support/core_ext/object/blank'
require 'cimaestro/configuration/serializer'
require 'cimaestro/configuration/path_builder'
require 'cimaestro/configuration/system_directory_structure_config'

module CIMaestro
  module Configuration
    class BuildConfig
      include PathBuilder

      class << self
        include PathBuilder

        def load(system_name = "", codeline_name = "", base_path = "")
          result = BuildConfig.new(system_name, codeline_name, base_path)

          path = get_config_path(result)

          config = Serializer.new(path).deserialize()
          result = config[0] if config != nil

          dir_structure = SystemDirectoryStructureConfig.new(result).get_directory_structure()
          result.directory_structure = dir_structure unless dir_structure == nil

          result
        end

        def clear(system_name = "", codeline_name = "", base_path = "")
          config_path = get_config_path(BuildConfig.new(system_name, codeline_name))
          Serializer.new(config_path).clear()
          config = self.load(system_name, codeline_name, base_path)
          SystemDirectoryStructureConfig.new(config).set_directory_structure()
          return config
        end
      end

      attr_reader :source_control, :system_name, :codeline_name, :base_path

      def initialize(system_name = "", codeline_name = "", base_path = "")
        @source_control = SourceControl.new
        @system_name = system_name
        @codeline_name = codeline_name
        @base_path = base_path
      end

      def save()
        config_path = get_config_path(self)
        serializer = Serializer.new(config_path)
        config = serializer.deserialize()
        if config != nil then
          config[0] = self
        else
          config = [self]
        end
        serializer.serialize(* config)

        SystemDirectoryStructureConfig.new(self).set_directory_structure()
      end

      def set_default_repository_path
        if not @system_name.blank? and
                not @codeline_name.blank? and
                not @base_path.blank? and
                @source_control.is_using_default_type? and
                not @source_control.has_repository_path? then
          @source_control.repository_path = create_directory_structure.solution_dir_path
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

      def base_path=(value)
        @base_path = value
        set_default_repository_path()
      end

      def create_directory_structure
        directory_structure.new(base_path, system_name, codeline_name)
      end

      def directory_structure
        @directory_structure ||= DefaultDirectoryStructure
      end

      def directory_structure=(value)
        value = value.to_class if value.class != Class
        @directory_structure = value
      end

      def merge!(other_conf, options = {:override=>false})
        [:system_name, :codeline_name, :version_number, :trigger_type, :task_name, :base_path, :directory_structure].each do |item|
          if (other_conf.send(item) and
              (options[:override] or instance_variable_get("@#{item}").blank?))

            self.send(item.to_s + "=", other_conf.send(item)) 
          end
        end
        @source_control.merge!(other_conf.source_control, options) if other_conf.source_control
      end
    end
  end
end

