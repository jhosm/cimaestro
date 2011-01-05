require 'active_support/core_ext/object/blank'
require 'cimaestro/utils/serializer'
require 'cimaestro/configuration/path_builder'
require 'cimaestro/configuration/system_directory_structure_config'
require 'cimaestro/utils/reflection'

module CIMaestro
  module Configuration
    class BuildConfig
      include PathBuilder
      include Utils::Reflection


      class << self
        include PathBuilder

        def exist?(system_name = "", codeline_name = "", base_path = "")
          load_saved_config(base_path, codeline_name, system_name) != nil
        end

        def load_saved_config(base_path, codeline_name, system_name)
          path = get_config_path(BuildConfig.new(system_name, codeline_name, base_path))
          Serializer.new(path).deserialize()
        end

        def load(system_name = "", codeline_name = "", base_path = "")
          saved_config = load_saved_config(base_path, codeline_name, system_name)

          config       = BuildConfig.new(system_name, codeline_name, base_path)
          config = saved_config[0] if saved_config != nil

          dir_structure = SystemDirectoryStructureConfig.new(config).get_directory_structure()
          config.directory_structure = dir_structure unless dir_structure == nil

          config
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
        @source_control      = SourceControl.new
        @system_name         = system_name
        @codeline_name       = codeline_name
        @base_path           = base_path
        @task_name           = nil
        @trigger_type        = nil
        @directory_structure = nil
      end

      def save()
        config_path = get_config_path(self)
        serializer  = Serializer.new(config_path)
        config      = serializer.deserialize()
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
            @source_control.is_using_default_system_proxy? and
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

        default_config = BuildConfig.new()

        instance_variables_as_hash().each_pair do |attr_reader, value|
          if (other_conf.respond_to?(attr_reader))
            if value.respond_to?(:merge!)
              value.merge!(other_conf.send(attr_reader), options)
            elsif (options[:override] or
                value == default_config.send(attr_reader) or
                value.blank?)
              self.send(attr_reader.to_s + "=", other_conf.send(attr_reader))
            end
          end
        end
      end

      def to_ostruct()

        instance_variables_as_hash().inject(OpenStruct.new) do |result, (property, value)|
          if value.respond_to?(:to_ostruct) then
            result.send(property.to_s + "=", value.to_ostruct())
          else
            result.send(property.to_s + "=", self.send(property))
          end
          result
        end
      end

    end
  end
end

