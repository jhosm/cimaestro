require 'rake'
require 'cimaestro'
require "required_references"

include Build

def execute_task(task_name)

  begin
    $registry[:logger].set_current_task(task_name)

    task_to_execute = $registry[task_name.to_sym].new(task_name, $registry[:build_spec], $registry[:logger])
    task = ExecutionTimeTask.new(task_to_execute,
                                 $registry[:build_spec],
                                 $registry[:logger])
    task.setup
    task.execute
  rescue => ex
    $registry[:logger].log_error(ex.message)
    raise
  end
end

def set_dependencies(default_dependencies)
  if ENV["NO_DEPENDENCIES"] == "true"
    [:setup_default_tasks]
  else
    default_dependencies
  end
end

desc "The root task\n"
task :default => [:post_publish] do
  $registry[:logger].log_msg("BUILD SUCCEEDED.")
end

"Default :post_publish, which does nothing. If a project needs customization, it should create a task with the same name in the file referenced in :load_customs_specs.\n"
task :post_publish => :publish do |t|
end

desc "Publishes all artifacts to the latest artifacts dir.\n"
task :publish => :pre_publish do |t|
  execute_task t.name
end

desc "Default :pre_publish, which does nothing. If a project needs customization, it should create a task with the same name in the file referenced in :load_customs_specs.\n"
task :pre_publish => set_dependencies(:compute_code_metrics) do |t|
end

desc "Computes code metrics.\n"
task :compute_code_metrics => set_dependencies(:analyze_code) do |t|
  execute_task t.name
end

desc "Does a static analysis of the code.\n"
task :analyze_code => set_dependencies(:run_dot_net_unit_tests) do |t|
  execute_task t.name
end

desc "Executes .Net unit tests. Searches for them in the working dir root.\n"
task :run_dot_net_unit_tests => set_dependencies(:create_strong_named_assembly_policy) do |t|
  execute_task t.name
end

desc "Creates policy files for all GAC assemblies. Searches for them in the working dir root.\n"
task :create_strong_named_assembly_policy => set_dependencies(:compile_dot_net) do |t|
  execute_task t.name
end

desc <<END_OF_STRING
Compiles .Net solutions. Searches for them in the working dir root.
Switches:
	- platform - Overrides the default build platform. The default is "Any CPU".
END_OF_STRING
task :compile_dot_net => set_dependencies(:set_common_assembly_attributes) do |t|
  execute_task t.name
end

desc "Ensures all .Net assemblies have some common metadata, most notably the version.\n"
task :set_common_assembly_attributes => :update_dependencies do |t|
  execute_task t.name
end

desc <<END_OF_STRING
Updates the dependencies needed for a successful compilation. Copies all the dependencies to a "lib" dir within the working directory.
Switches:
	- dependencies_files - The set of dependencies to copy to the lib dir. Default: The Latest versions of Stq.WorkflowRuntime.dll and Stq.Common.dll, from the build's codeline.
END_OF_STRING
task :update_dependencies => set_dependencies(:make_versioned_file_names) do |t|
  execute_task t.name
end


desc <<END_OF_STRING
Creates copies of files, versioning their names. Useful for caching files on the browser, without the disadvantages (stale data).
Switches:
	- files_to_version - The set of files that should be versioned. Default: All the "xsl", "xslt", "htm", "html" and "css" files within the solution.
END_OF_STRING
task :make_versioned_file_names => set_dependencies(:replace_css_references) do |t|
  execute_task t.name
end

desc <<END_OF_STRING
Replaces the css references. Useful for caching css files on the browser, without the disadvantages (stale data).
Needs to have the make_versioned_file_names task executed first.
Switches:
	- css_referencing_files - The set of files that reference css files. Default: All the "xsl", "xslt", "htm", "html", "asp" and "aspx" files within the solution.
	- files_to_version - The set of files that should be versioned. Default: All the "xsl", "xslt", "htm", "html" and "css" files within the solution.
										 - MUST BE EQUAL to the files_to_version of the make_versioned_file_names task.
END_OF_STRING
task :replace_css_references => set_dependencies(:minify_javascript) do |t|
  execute_task t.name
end

desc <<END_OF_STRING
Minimizes javascript files included in "Site-*\GeneratedJS" folders.
Switches:
	- files_to_minify - The set of javascript files to minimize. Default: All the "js", files within GeneratedJS folder inside the "Site" projects.
END_OF_STRING
task :minify_javascript => set_dependencies(:merge_web_files) do |t|
  execute_task t.name
end

desc <<END_OF_STRING
Merges web files. Currently only supports js files.
Switches:
	- js_referencing_files - The set of files that reference js files. Default: All the "xsl", "xslt", "htm", "html", "asp" and "aspx" files within the solution.
END_OF_STRING
task :merge_web_files => set_dependencies(:version_sites) do |t|
  execute_task t.name
end

desc "Create a version.htm on the root of the solution's sites with the build version and date.\n"
task :version_sites => set_dependencies(:validate_and_minimize_xml_files) do |t|
  execute_task t.name
end

desc "Verifies that all .xml, .xsd and .xsl are well formed xml files\n"
task :validate_and_minimize_xml_files => set_dependencies(:merge_xsl_files) do |t|
  execute_task t.name
end

desc <<END_OF_STRING
Merge xsl files, by replacing include tags with the contents of the file referenced
Switches:
	- excluded_path_fragment - When searching for an xsl, this fragment is removed from the path. Must be a regular expression. Default: empty string.
	- xsl_files - The set of xsl files that should be merged. Default: All the xsl and xslt files within a "Site" project.
END_OF_STRING
task :merge_xsl_files => set_dependencies(:get_sources) do |t|
  execute_task t.name
end

desc "Gets sources from local solution dir, if the SOURCE_CONTROL environment variable is equal to \"local\", or from the subversion repository.\n"
task :get_sources => :purge do |t|
  execute_task t.name
end

desc "Removes working directory.\n"
task :purge => :setup_default_tasks do |t|
  execute_task t.name
end

desc "Specifies the default tasks to execute.\n"
task :setup_default_tasks => :setup_custom_specs do
  $registry[:compute_code_metrics] ||= ComputeCodeMetrics
  $registry[:analyze_code] ||= AnalyzeCodeTask
  $registry[:run_dot_net_unit_tests] ||= RunDotNetUnitTestsTask
  $registry[:create_strong_named_assembly_policy] ||= CreateStrongNamedAssemblyPolicyTask
  $registry[:compile_dot_net] ||= CompileDotNetTask
  $registry[:set_common_assembly_attributes] ||= SetCommonAssemblyAttributesTask
  $registry[:update_dependencies] ||= UpdateDependenciesTask
  $registry[:validate_and_minimize_xml_files] ||= ValidateAndMinimizeXmlFilesTask
  $registry[:version_sites] ||= VersionSitesTask
  $registry[:get_sources] ||= GetSourcesTask

  if ENV["TRIGGER"] == "IntervalTrigger" && ENV["CODELINE"] != "Release" then
    $registry[:publish] ||= NullTask
    $registry[:purge] ||= NullTask
    $registry[:merge_xsl_files] ||= NullTask
    $registry[:make_versioned_file_names] ||= NullTask
    $registry[:replace_css_references] ||= NullTask
    $registry[:merge_web_files] ||= NullTask
  else
    $registry[:publish] ||= PublishTask
    $registry[:purge] ||= PurgeTask
    $registry[:merge_xsl_files] ||= MergeXslFilesTask
    $registry[:make_versioned_file_names] ||= MakeVersionedFileNamesTask
    $registry[:replace_css_references] ||= ReplaceCssReferencesTask
    $registry[:merge_web_files] ||= MergeWebFilesTask
    $registry[:minify_javascript] ||= MinifyJavascriptTask
  end
end

desc "Default :setup_custom_specs, which does nothing. If a project needs customization, it should create a task with the same name in the file referenced in :load_customs_specs.\n"
task :setup_custom_specs => :load_customs_specs do
end

desc "Load customs build specs, if it exists. Custom specs must be located in '<project build dir>\<system_name>_rakefile.rb'.\n"
task :load_customs_specs => :setup_build_spec do
  $: << $registry[:build_spec].build_scripts_dir_path

  customs_specs_path = File.join($registry[:build_spec].build_scripts_dir_path, $registry[:build_spec].system_name + "_rakefile.rb")
  import customs_specs_path if File.exists?(customs_specs_path)
end

desc "Prepares build, by creating a Build Specification and the Logger.\n"
task :setup_build_spec do
  config = $build_config

  cimaestro_configuration_path = File.join(config.base_path, ".cimaestro", "cimaestro.rb")
  import cimaestro_configuration_path if File.exists?(cimaestro_configuration_path)

  build_spec = BuildSpec.new("", "", "", "", config)

  if ENV["LOG_TO_FILE"] == "true" then
    logger = NAntCompatibleXmlLogger.new build_spec.system_name, File.join(build_spec.logs_dir_path, "build-results.xml")
  else
    logger = ConsoleLogger.new
  end

  $registry[:build_spec] = build_spec
  $registry[:logger] = logger
end

