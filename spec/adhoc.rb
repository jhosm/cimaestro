$:.unshift "../lib"
require "../lib/required_references"
require "../lib/cimaestro"
CIMaestro::Application::BuildCommand.new.parse_options(['-S', 'CIMaestro', '-c', 'Mainline', '-n','1.0.0.0'])


