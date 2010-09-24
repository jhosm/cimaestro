$stderr =  StringIO.new

require "spec"
require "uuid"
require "lib/required_references"
require "lib/cimaestro"
require "system_file_structure_mocker"

TESTS_SOURCE_FILES = "./spec/TestSourceFiles"
TESTS_BASE_PATH = "./spec/Tests"
rm_rf TESTS_BASE_PATH



class String
  def camelize(first_letter_in_uppercase = true)
       if first_letter_in_uppercase
         self.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
       else
         self.first + camelize(self)[1..-1]
       end
  end

  def underscore()
    self.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end

def create_task(klass, system_name="aSystem", codeline="Release", version="1.5.8.7")
  build_spec = BuildSpec.new(TESTS_BASE_PATH, system_name, codeline, version)
  task = klass.new klass.to_s.underscore.to_sym, build_spec, NullLogger.new
  return task, build_spec
end

