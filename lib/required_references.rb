require 'uuid'
require 'win32ole'
require 'rake'
require 'rake/tasklib'
require 'rexml/document'
require 'forwardable'

require 'cimaestro/source_control/svn'
require 'cimaestro/source_control/source_control_factory'
require 'cimaestro/build_configuration/build_model'
require 'cimaestro/build_configuration/default_directory_structure'
require 'cimaestro/ruby_extensions/hash/reverse_merge'
require 'cimaestro/ruby_extensions/string/reflection'
require 'loggers'
require 'registry'

include CIMaestro::BuildConfiguration


