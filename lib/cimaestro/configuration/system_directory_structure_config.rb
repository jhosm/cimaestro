require 'cimaestro/configuration/path_builder'

module CIMaestro
  module Configuration
    class SystemDirectoryStructureConfig
      include PathBuilder

      SYSTEMS_DIRECTORY_STRUCTURES_DOC_INDEX = 1

      def initialize(build_config)
        @build_config = build_config
        @serializer = Serializer.new(get_config_path())
      end

      def load_directory_structure
        systems_directory_structures = {}
        config = @serializer.deserialize()
        return systems_directory_structures if config == nil

        if config.size <= SYSTEMS_DIRECTORY_STRUCTURES_DOC_INDEX then
          save_directory_structure(systems_directory_structures)
          return systems_directory_structures
        end

        config[SYSTEMS_DIRECTORY_STRUCTURES_DOC_INDEX]
      end

      def save_directory_structure(systems_directory_structures)
        config = @serializer.deserialize()
        return if config == nil
        if config.size <= SYSTEMS_DIRECTORY_STRUCTURES_DOC_INDEX then
          config.push(systems_directory_structures)
        else
          config[SYSTEMS_DIRECTORY_STRUCTURES_DOC_INDEX] = systems_directory_structures
        end

        @serializer.serialize(*config)
      end

      def get_directory_structure_key
        @build_config.system_name + "-" + @build_config.codeline_name
      end

      def get_directory_structure
        systems_directory_structures = load_directory_structure()
        key = get_directory_structure_key()
        systems_directory_structures[key] if systems_directory_structures.has_key?(key)
      end

      def set_directory_structure
        systems_directory_structures = load_directory_structure()
        key = get_directory_structure_key()

        systems_directory_structures[key] = @build_config.directory_structure

        save_directory_structure(systems_directory_structures)
      end

    end
  end
end