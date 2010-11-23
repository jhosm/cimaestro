$:.unshift "../lib"
require "required_references"
          CIMaestro::Application::ConfigCommand.new.run(['--sc_type', 'CIMaestro::SourceControl::Svn'])
