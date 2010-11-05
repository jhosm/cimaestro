module CIMaestro
  module Configuration
    class SourceControl
      attr_accessor :username, :password

      def initialize
        @repository_path = nil
      end

      def type
        @type ||= ::CIMaestro::SourceControl::FileSystem
      end

      def type=(value)
        @type = value
      end

      def is_using_default_type?
        type.to_s == "CIMaestro::SourceControl::FileSystem"
      end

      def has_repository_path?
        @repository_path != nil
      end

      def repository_path
        if @repository_path == nil then
          raise Exceptions::InvalidBuildSpecException, "Please specify a source control repository path."
        end
        @repository_path
      end

      def repository_path=(value)
        @repository_path = value
      end

      def merge!(other_conf)
        [:type, :repository_path, :username, :password].each do |item|
          self.send(item.to_s + "=", other_conf.send(item)) if instance_variable_get("@#{item}").blank?
        end
      end

    end
  end
end
