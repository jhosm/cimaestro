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

      def merge!(other_conf, options = {:override=>false})
        [:type, :repository_path, :username, :password].each do |item|
          other_conf_has_item = (other_conf.class == self.class and not other_conf.instance_variable_get("@#{item}").blank?) or
                  (other_conf.class != self.class and other_conf.send(item))
          should_set_item =  (options[:override] or instance_variable_get("@#{item}").blank?)
          if (other_conf_has_item and should_set_item) then
            self.send(item.to_s + "=", other_conf.send(item))
          end
        end
      end

    end
  end
end
