module CIMaestro
  module Application
    module CommandLineOptions

      BUILD_OPTIONS = {
        :system_name => ['-S NAME', '--system NAME', 'The NAME of the system to be built'],
        :codeline_name => ['-c NAME', '--codeline NAME', 'The NAME of the codeline to build'],
        :task_name => ['-T TASK_NAME','--task TASK_NAME', 'The TASK_NAME to execute.',
                                                               'Defaults to "default"'],
        :trigger_type =>['-t TRIGGER_TYPE', '--trigger TRIGGER_TYPE', 'What triggered the build.',
                                                                         'Defaults to "forced".'],
        :version_number => ['-n VERSION_NUMBER','--version_number VERSION_NUMBER', 'The version of the build, if it succeeds.'],
        :trace => ['--trace', 'Print the stack trace, if the build throws.'],
        :base_path => ['-p BASE_PATH', '--path BASE_PATH', 'The system''s base path. Inside this directory ',
                                                                'should be the system''s directory.'],
        :directory_structure => ['-d DIRECTORY_STRUCTURE', '--directory_structure DIRECTORY_STRUCTURE', 'The name of the Ruby class which defines',
                                                                                                   'the directory structure.',
                                                                                                   'Check CIMaestro::Configuration::',
                                                                                                   'DefaultDirectoryStructure docs.'],
        'source_control!system' => ['--sc_type SOURCE_CONTROL_TYPE', 'The name of the Ruby class which',
                                                                    ' proxies the source control system'],
        'source_control!repository_path' => ['--sc_path REPOSITORY_PATH', 'The location of the system',
                                                                       ' in the source control''s repository.'],
        'source_control!username' => ['--sc_user USERNAME', 'The user name to use when',
                                                                       ' talking with the source control.'],
        'source_control!password' => ['--sc_password PASSWORD', 'The password to use when',
                                                                       ' talking with the source control.'],
      }
    end
  end
end