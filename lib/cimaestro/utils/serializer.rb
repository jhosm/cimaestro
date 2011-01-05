require 'yaml'

module CIMaestro
  module Configuration
    class Serializer

      def initialize(path)
        @path = path + ".yaml"
      end
      
      def deserialize()
        return nil unless File.exist?(@path)
        File.open(@path) do |file|
          return YAML::load_stream(file).documents
        end
      end

      def serialize(*objs_to_dump)
        dir = File.dirname(@path)
        FileUtils.mkpath(dir) unless File.exist?(dir)
        File.open(@path, "w+") do |file|
          puts "writing in" + File.expand_path(@path)
          file.puts(YAML::dump_stream(*objs_to_dump))
        end
      end

      def clear()
        File.delete(@path) if File.exist?(@path)
      end
    end
  end
end
