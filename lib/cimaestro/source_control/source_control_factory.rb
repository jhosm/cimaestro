require 'FileUtils'

module CIMaestro
  module SourceControl

    class SourceControlFactory
      def SourceControlFactory.create(local_path, repository_path = nil)
        Svn.new(local_path, repository_path)
      end
    end
  end
end