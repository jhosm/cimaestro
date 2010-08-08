require 'FileUtils'

module CIMaestro
  module SourceControl
    class Svn
      include FileUtils

      attr_reader :repository_path, :local_path, :last_command

      def initialize(local_path, repository_path = nil)
        @repository_path = repository_path
        @local_path = local_path
      end

      def checkout
        please_do("co \"#{@repository_path}\"")
      end

      def update
        please_do("update")
      end

      def commit(message)
        please_do("commit --message \"#{message}\"")
      end

      def add(item)
        please_do("add --force", File.join(@local_path, item))
      end

      def delete(item)
        please_do("delete", File.join(@local_path, item))
      end

      private

      def please_do(command, path=@local_path)
        @last_command =  "svn #{command} \"#{path}\""
        sh(@last_command)
      end
    end
  end
end