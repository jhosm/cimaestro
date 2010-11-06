module CIMaestro
  module Configuration
    class SourceControl
      attr_accessor :username, :password

      def initialize
        @repository_path = nil
      end

      def system
        @system ||= ::CIMaestro::SourceControl::FileSystem
      end

      def system=(value)
        @system = value.to_class
      end

      def is_using_default_type?
        system.to_s == "CIMaestro::SourceControl::FileSystem"
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
        default_source_control = SourceControl.new
        [:system, :repository_path, :username, :password].each do |item|
          other_conf_has_item = ((other_conf.class == self.class and not other_conf.instance_variable_get("@#{item}").blank?) or (other_conf.class != self.class and other_conf.respond_to?(item))) == true
          should_set_item =  (options[:override] or instance_variable_get("@#{item}") == default_source_control.instance_variable_get("@#{item}"))
          if (other_conf_has_item and should_set_item) then
            self.send(item.to_s + "=", other_conf.send(item))
          end
        end
      end

    end
  end
end
