require 'rubygems' unless $LOAD_PATH.include? 'rubygems'
unless $LOAD_PATH.include? 'bundler' then
  require 'bundler'
  Bundler.setup
end


require 'rake'
require 'uuid'
require 'win32ole'
require 'rake/tasklib'
require 'rexml/document'
require 'forwardable'
require 'active_support'
require 'yaml'

module CIMaestro
  class CIMaestro
    VERSION = '1.0.0'
    ROOT_PATH = File.expand_path(File.dirname(File.dirname(__FILE__)))
  end
end

require 'cimaestro/application/command_line'
require 'cimaestro/application/command_line_options'
require 'cimaestro/application/command_line_parser'
require 'cimaestro/application/command_line_command'
require 'cimaestro/application/build_command'
require 'cimaestro/application/config_command'
require 'cimaestro/application/install_command'
require 'cimaestro/application/smoke_command'
require 'cimaestro/application/option_not_specified_exception'
require 'cimaestro/application/unknown_application_command_exception'
require 'cimaestro/configuration/invalid_build_spec_exception'
require 'cimaestro/configuration/build_model'
require 'cimaestro/configuration/source_control'
require 'cimaestro/configuration/build_config'
require 'cimaestro/source_control/svn'
require 'cimaestro/source_control/file_system'
require 'cimaestro/configuration/default_directory_structure'
require 'cimaestro/ruby_extensions/class/yaml'
require 'cimaestro/ruby_extensions/string/reflection'
require 'loggers'
require 'registry'


include CIMaestro::Configuration


