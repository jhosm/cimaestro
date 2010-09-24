module CIMaestro
  module SourceControl
    class FileSystem
      include ::Build::ShellUtils

      attr_reader :repository_path, :local_path
      
      def initialize(local_path, repository_path, username = "", password = "")
        @repository_path = repository_path
        @local_path = local_path
      end

      def checkout
        logger.log_msg "If '#{@repository_path}' exists, copy it to '#{@local_path}'."
        FileUtils.cp_r(File.join(@repository_path, "."), @local_path)
        exec_and_log("attrib -R #{File.join(@local_path, "*.*")} /S")
      end

      #HACK: It's here only temporarily, before we have a consistent logging solution
      def logger
        ConsoleLogger.new
      end
    end
  end
end
