module CIMaestro
  module Application
    module CommandLineOptions

      INSTALLER_OPTIONS = {
        :gem_home => ["-g HOME", "--gem_home HOME", 'Setup cimaestro environment,',
                                                         'If GEM_HOME is not specified, bundler\'s',
                                                         'default will be used.']
      }

      BUILD_OPTIONS = {
        :system_name => ['-S NAME', '--system NAME', 'The NAME of the system to be built'],
        :codeline_name => ['-c NAME', '--codeline NAME', 'The NAME of the codeline to build'],
        :task_name => ['-T TASK_NAME','--task TASK_NAME', 'The TASK_NAME to execute.',
                                                               'Defaults to "default"'],
        :trigger_type =>['-t TRIGGER_TYPE', '--trigger TRIGGER_TYPE', 'What triggered the build.',
                                                                         'Defaults to "forced".'],
        :version_number => ['-n VERSION_NUMBER','--version_number VERSION_NUMBER', 'The version of the build, if it succeeds.'],
        :trace => ['--trace', 'Print the stack trace, if the build throws.']
      }

      CONFIGURATION_OPTIONS = {
        :base_path => ['-p BASE_PATH', '--path BASE_PATH', 'The system''s base path. Inside this directory ',
                                                                'should be the system''s directory.'],
        :directory_structure => ['-d DIRECTORY_STRUCTURE', '--directory_structure DIRECTORY_STRUCTURE', 'The name of the Ruby class which defines',
                                                                                                   'the directory structure.',
                                                                                                   'Check CIMaestro::Configuration::',
                                                                                                   'DefaultDirectoryStructure docs.']
      }
    end
  end
end