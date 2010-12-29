require 'cimaestro/utils/reflection'

module CIMaestro
  module Configuration
    class SourceControl
      include Utils::Reflection
      PROPERTIES = [:system_proxy, :repository_path, :username, :password]
      attr_accessor :username, :password

      def initialize
        @repository_path = nil
        @system_proxy = nil
        @username = nil
        @password = nil
      end

      def system_proxy
        @system_proxy ||= ::CIMaestro::SourceControl::FileSystem
      end

      def system_proxy=(value)
        @system_proxy = value.to_class
      end

      def is_using_default_system_proxy?
        system_proxy.to_s == "CIMaestro::SourceControl::FileSystem"
      end

      def has_repository_path?
        @repository_path != nil
      end

      def repository_path
        @repository_path
      end

      def repository_path=(value)
        @repository_path = value
      end

      def merge!(other_conf, options = {:override=>false})
        default_source_control = SourceControl.new
        instance_variables_as_hash().each_pair do |k ,v|
          other_conf_has_item = ((other_conf.class == self.class and not other_conf.send(k).blank?) or (other_conf.class != self.class and other_conf.respond_to?(k))) == true
          should_set_item =  (options[:override] or v == default_source_control.send(k))
          if (other_conf_has_item and should_set_item) then
            self.send(k.to_s + "=", other_conf.send(k))
          end
        end
      end

       def to_ostruct()
        instance_variables_as_hash().inject(OpenStruct.new) do |result, (k, v)|
          result.send(k.to_s + "=", v)
          result
        end
      end
    end
  end
end
