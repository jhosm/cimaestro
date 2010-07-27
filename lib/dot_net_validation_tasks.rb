require "required_references"
module Build
  class ComputeCodeMetrics < Task
    include Build::ShellUtils

    attr_accessor :command_line

    def initialize(rake_name, build_spec, logger)
      super(rake_name, build_spec, logger)
      @command_line = ""
    end

    def setup
      @source_monitor_command = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
      @source_monitor_command += "<sourcemonitor_commands>"
      @source_monitor_command += "	<command>"
      @source_monitor_command += "		<project_file>#{File.join(build_spec.working_dir_path, "sm_project.smp")}</project_file>"
      @source_monitor_command += "		<project_language>CSharp</project_language>"
      @source_monitor_command += "		<source_directory>#{build_spec.working_dir_path}</source_directory>"
      @source_monitor_command += "		<include_subdirectories>true</include_subdirectories>"
      @source_monitor_command += "		<checkpoint_name>#{build_spec.version}</checkpoint_name>"
      @source_monitor_command += "		<export>"
      @source_monitor_command += "			<export_file>#{File.join(build_spec.logs_dir_path, "sm_summary-results.xml")}</export_file>"
      @source_monitor_command += "			<export_type>1</export_type>"
      @source_monitor_command += "		</export>"
      @source_monitor_command += "	</command>"
      @source_monitor_command += "	<command>"
      @source_monitor_command += "		<project_file>#{File.join(build_spec.working_dir_path, "sm_project.smp")}</project_file>"
      @source_monitor_command += "		<checkpoint_name>#{build_spec.version}</checkpoint_name>"
      @source_monitor_command += "		<export>"
      @source_monitor_command += "			<export_file>#{File.join(build_spec.logs_dir_path, "sm_details-results.xml")}</export_file>"
      @source_monitor_command += "			<export_type>2</export_type>"
      @source_monitor_command += "		</export>"
      @source_monitor_command += "	</command>"
      @source_monitor_command += "</sourcemonitor_commands>"

      File.open(File.join(build_spec.working_dir_path, "sourcemonitor.xml"), "w") do |f|
        f.puts @source_monitor_command
      end

      @command_line = "\"" + File.join(build_spec.tools_dir_path, "SourceMonitor", "SourceMonitor") + "\" "
      @command_line += "/C \"" + File.join(build_spec.working_dir_path, "sourcemonitor.xml\" ")

    end

    def execute
      FileUtils.mkpath(build_spec.logs_dir_path) unless File.exist?(build_spec.logs_dir_path)

      exec_and_log(@command_line)

      results_path = File.join(build_spec.logs_dir_path, "sm_details-results.xml")

      xslt = WIN32OLE.new("MSXML2.DOMDocument.3.0")
      xslt.load(File.join(File.dirname(__FILE__), "SourceMonitorSummaryGeneration.xsl"))
      xml_report = WIN32OLE.new("MSXML2.DOMDocument.3.0")
      xml_report.load(results_path)
      File.open(results_path, "w") do |f|
        f.puts xml_report.transformNode(xslt)
      end
    end
  end

  class AnalyzeCodeTask < Task
    include Build::ShellUtils

    attr_accessor :command_line, :src_control
    attr_reader :rules_path, :benchmark_report_path, :report_path

    def initialize(rake_name, build_spec, logger)
      super(rake_name, build_spec, logger)
      @command_line = ""
      @rules_path = File.join(build_spec.tools_dir_path, "FxCop", "Rules")
      @src_control = SourceControlFactory.create(build_spec.build_scripts_dir_path, build_spec.source_control_repository_path+"/"+Build::BUILD_SCRIPTS_DIR)
      @benchmark_report_path = File.join(build_spec.build_scripts_dir_path, "benchmark-report-fxcop.xml")
      @report_path = File.join(build_spec.logs_dir_path, "report-fxcop.xml")
    end

    def setup
      @command_line = "\"" + File.join(build_spec.tools_dir_path, "FxCop", "FxCopCmd") + "\" "

      @projects_to_analyze = build_spec.get_projects_of([ProjectType::ASSEMBLY, ProjectType::GAC_ASSEMBLY, ProjectType::WINDOWS_SERVICE, ProjectType::ACTIVITIES_ASSEMBLY])
      @command_line = @projects_to_analyze.inject(@command_line) do |cmd, project|

        excluded_files = build_spec.get_spec_for(rake_name, :projects_to_exclude, [])
        if !excluded_files.include?(project.name)
          cmd += "/f:\"#{project.path}\\bin\\#{build_spec.solution_build_config}\\#{project.name}"
          cmd += ".dll\" " unless project.type == ProjectType::WINDOWS_SERVICE
          cmd += ".exe\" " if project.type == ProjectType::WINDOWS_SERVICE
        end
        cmd
      end

      specify_custom_rules("/rule:+", :enabled_assembly_rules)
      specify_custom_rules("/rule:-", :disabled_assembly_rules)
      specify_custom_rules("/ruleid:+", :enabled_rules)
      specify_custom_rules("/ruleid:-", :disabled_rules)

      @command_line += "/d:" + build_spec.lib_dir_path + " "
      @command_line += "/gac "
      @command_line += "/o:" + @report_path + " "
    end

    protected

    def specify_custom_rules(option_value, option_name)
      build_spec.get_spec_for(rake_name, option_name, []).each do |option|
        if /\/rule:/ =~ option_value
          @command_line += " #{option_value}#{File.join(rules_path, option)} "
        else
          @command_line += " #{option_value}#{option} "
        end
      end
    end

    public

    def execute
      FileUtils.mkpath(build_spec.logs_dir_path) unless File.exist?(build_spec.logs_dir_path)

      exec_and_log(@command_line, [9]) if @projects_to_analyze.size > 0

      benchmark = Benchmark.new(@benchmark_report_path, @report_path, BuildVersion.new(build_spec.version, :ignore_revision), @src_control)
      benchmark.validate_and_update do |benchmark_report, report|
        [benchmark_report.root.elements.to_a("//Issue").length, report.root.elements.to_a("//Issue").length]
      end 
    end
  end

  class RunDotNetUnitTestsTask < Task
    include Build::ShellUtils

    attr_reader :command_line

    def initialize(rake_name, build_spec, logger)
      super(rake_name, build_spec, logger)
      @command_line = ""
    end

    def setup
      @command_line = "\"" + File.join(build_spec.tools_dir_path, "PartCover", "PartCover") + "\" "

      @command_line += "--target=" + File.join(build_spec.tools_dir_path, "NUnit", "bin", "nunit-console.exe") + " "

      @command_line += "--target-args=\""
      unit_tests_projects = build_spec.get_projects_of(ProjectType::UNIT_TEST)
      @command_line = unit_tests_projects.inject(@command_line) do |cmd, project|
        cmd + File.join(project.path, "bin", build_spec.solution_build_config, project.name + ".dll") + " "
      end

      @command_line += "/xml:" + File.join(build_spec.logs_dir_path, "tests-results.xml")
      @command_line += "\" "

      projects_to_cover = build_spec.get_projects_of([ProjectType::ASSEMBLY, ProjectType::GAC_ASSEMBLY, ProjectType::ACTIVITIES_ASSEMBLY])
      @command_line = projects_to_cover.inject(@command_line) do |cmd, project|
        cmd + "--include=[#{project.name}]* "
      end

      @command_line += specify_custom_rules(:include)

      @command_line = unit_tests_projects.inject(@command_line) do |cmd, project|
        cmd + "--exclude=[#{project.name}]* "
      end

      @command_line += specify_custom_rules(:exclude)

      @command_line += "--output=" + File.join(build_spec.logs_dir_path, "code-coverage-results.xml")
    end

    protected

    def specify_custom_rules(rule_type)
      rule = build_spec.get_spec_for(rake_name, rule_type, "")
      return "" if rule.empty?
      rule = [rule] if rule.class == String
      rule.inject("") do |memo, item|
        memo + "--#{rule_type}=#{item} "
      end
    end

    public

    def execute
      return if build_spec.get_projects_of(ProjectType::UNIT_TEST).length == 0

      FileUtils.mkpath(build_spec.logs_dir_path) unless File.exist?(build_spec.logs_dir_path)

      logger.log_msg Dir.pwd
      exec_and_log(@command_line)
      raise ".Net Unit Tests failed" if not verify_tests_results
    end

    protected

    def verify_tests_results
      file = File.read(File.join(build_spec.logs_dir_path, "tests-results.xml"))
      results = Document.new file
      return false if results.elements.to_a("//failure").length > 0
      return true
    end
  end
end