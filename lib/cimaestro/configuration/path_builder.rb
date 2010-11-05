module CIMaestro
  module Configuration
    module PathBuilder
      def get_config_path(build_config = nil)
        if build_config == nil or build_config.system_name.blank? then
          path = CIMaestro::ROOT_PATH
        else
          path = build_config.create_directory_structure.cimaestro_dir_path
        end
        File.join(path, "_config")
      end
    end
  end
end
