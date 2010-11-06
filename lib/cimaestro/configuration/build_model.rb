require 'cimaestro/configuration/build_config'
require 'forwardable'


module BuildTrigger
  FORCED = "forced"
end

module ProjectType
  ACTIVITIES_ASSEMBLY = "ACT"
  ASSEMBLY = "ASM"
  UNIT_TEST = "UnitTests"
  WINDOWS_SERVICE = "SVC"
  GAC_ASSEMBLY = "GAC"
  SITE = "Site"
  WEB_SERVICE = "WS"
  WCF_SITE = "WCFIIS"
end

module Build
  DEFAULT_SOLUTION_BUILD_CONFIGURATION = "Release"
  SVN_REPOSITORY = "http://sc1diisapp3:8448/svn/rep"
  SVN_TOOLS_REPOSITORY = "http://sc1diisapp3:8448/svn/tools"
  DOT_NET_SDK_PATH = "C:/WINDOWS/Microsoft.NET/Framework/v3.5"
  DOT_NET_2_0_SDK_PATH = "C:/WINDOWS/Microsoft.NET/Framework/v2.0.50727"
  WEB_SERVICES_DEPLOY_PATH = "//SC1DSERVIC1/Netdados/Inetpub"
  SITES_DEPLOY_PATH = "//sc1diisapp1/Netdados/Inetpub"
  WCF_SITES_DEPLOY_PATH = "//sc1dproces1/Netdados/Inetpub"
  TOOLS_BUILD_DIR = "Build"
end

module Build::ShellUtils
  def capture_output
    orig_stderr = $stderr
    orig_stdout = $stdout
    out = StringIO.new
    $stderr = out
    $stdout = out
    yield
    return out
  ensure
    $stderr = orig_stderr
    $stdout = orig_stdout
  end

  def exec_and_log(command, result_codes_to_ignore = [])
    logger.log_msg(command)
    log = capture_output do
      begin
        verbose_flag = RakeFileUtils.verbose_flag
        RakeFileUtils.verbose_flag = false
        sh(command) do |ok, res|
          if !ok && !result_codes_to_ignore.include?(res.exitstatus)
            raise command + " failed with result code (" + res.exitstatus.to_s + ")"
          end
        end
      ensure
        RakeFileUtils.verbose_flag = verbose_flag
      end
    end
    logger.log_msg(log.string)

  end
end

class ArgValidation
  def self.check_empty_string(value, name)
    raise ArgumentError, "#{name} cannot be null or empty." if (value == nil || value.empty?)
  end
end

class Project
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def full_name
    File.basename(path)
  end

  def name
    File.basename(path).split("-")[1]
  end

  def type
    File.basename(path).split("-")[0]
  end
end

module CIMaestro
  module Configuration

    class BuildSpec

      extend Forwardable
      def_delegators :@directory_structure, :system_base_path, :working_dir_path, :solution_dir_path, :latest_artifacts_dir_path,
                     :artifacts_dir_path, :lib_dir_path, :logs_dir_path, :cimaestro_dir_path, :solution_dir, :cimaestro_dir

      def_delegators :@global_conf, :system_name, :codeline_name, :version_number, :version_number=

      alias :project_dir_path :system_base_path
      alias :build_scripts_dir_path :cimaestro_dir_path
      alias :version :version_number
      alias :codeline :codeline_name

      attr_reader :custom_specs
      attr_accessor :base_path

      def initialize(base_path, system, codeline, version, conf = BuildConfig.load)

        conf.base_path = base_path unless base_path.empty?
        @base_path = conf.base_path

        @custom_specs = {}

        @global_conf = conf
        @global_conf.system_name = system unless system.empty?
        @global_conf.codeline_name = codeline unless codeline.empty?
        @global_conf.version_number = version unless version.empty?

        @directory_structure = @global_conf.directory_structure.new(@global_conf.base_path, @global_conf.system_name, @global_conf.codeline_name)

      end

      def custom_specs_for(task_name)
        @custom_specs[task_name.to_sym] = {} unless @custom_specs.has_key?(task_name.to_sym)
        @custom_specs[task_name.to_sym]
      end

      def get_spec_for(task_name, spec, spec_default = "")
        if custom_specs_for(task_name).has_key?(spec)
          custom_specs_for(task_name)[spec]
        else
          spec_default
        end
      end

      def last_successful_build_version
        version = ""
        File.open(File.join(latest_artifacts_dir_path, "version.txt"), "r") do |file|
          version = file.read
        end
        version.chomp
      end

      def get_file_list(file_extensions, task_name = "", override_key="", projects = nil)
        if task_name != "" and custom_specs_for(task_name.to_sym).has_key?(override_key)
          result = custom_specs_for(task_name.to_sym)[override_key]
        else
          result = FileList[]
          file_extensions.each do |extension|
            if projects == nil
              result.include(File.join(working_dir_path, "**", "*." + extension))
            else
              projects = [projects] unless projects.respond_to? :each
              projects.each do |project|
                path = File.join(working_dir_path, project.full_name)
                result.include(File.join(path, "**", "*." + extension))
              end
            end
          end
        end

        result
      end

      def get_projects_of(project_types)
        ArgValidation.check_empty_string(project_types, :project_types) if project_types === String
        project_types = project_types.to_a

        project_types.inject([]) do |result, project_type|
          projects = FileList[File.join(working_dir_path, project_type + "*")].map do |path|
            Project.new(path)
          end
          result.concat(projects)
        end
      end

      def extract_project_path(file_path)
        project_path_reg_exp = working_dir_path.gsub(/\./, '\.') + '/[^/]+'
        project_path = file_path.match(project_path_reg_exp)
        raise "Couldn't find the project path from '#{file_path}'." if project_path == nil
        return project_path[0]
      end

      def solution_build_config
        Build::DEFAULT_SOLUTION_BUILD_CONFIGURATION
      end

      def tools_dir_path
        File.join(@base_path, "..", "_Tools")
      end

      def src_control
        @global_conf.source_control.system.new(working_dir_path,
                                             @global_conf.source_control.repository_path,
                                             @global_conf.source_control.username,
                                             @global_conf.source_control.password)
      end
    end

    class FilenameVersionizer
      def versionize_and_copy_files(file_list, version)
        return if file_list == nil
        file_list.each do |file_path|
          file_path_with_version = File.join(
                  File.dirname(file_path),
                  versionize(file_path, version)
          )
          copy_file(file_path, file_path_with_version)
        end
      end

      def versionize(file_path, version)
        version + File.basename(file_path, File.extname(file_path)) + File.extname(file_path)
      end
    end

    class BuildVersion
      attr_accessor :should_ignore

      def initialize(version, should_ignore = "")
        @version = version
        @should_ignore = should_ignore
      end

      def major
        @version.split('.')[0]
      end

      def minor
        @version.split('.')[1]
      end

      def build
        @version.split('.')[2]
      end

      def revision
        @version.split('.')[3]
      end

      def to_s
        @version
      end

      def >(other)
        return false if self == other
        return true if (major > other.major)
        return false if (major < other.major)
        return true if (minor > other.minor)
        return false if (minor < other.minor)
        return true if (build > other.build)
        return false if (build < other.build)
        return true if (@should_ignore == :ignore_revision)
        return true if (revision > other.revision)
        return false if (revision < other.revision)
      end

      def ==(other)
        if (@should_ignore == :ignore_revision)
          return major == other.major && minor == other.minor && build == other.build
        end
        @version == other.to_s
      end

      def >=(other)
        self == other || self > other
      end

      def <(other)
        self != other && !(self > other)
      end

      def <=(other)
        self < other || self == other
      end
    end

    class Benchmark

      attr_reader :validation_error_message

      def initialize(benchmark_report_path, report_path, build_version)
        @benchmark_report_path = benchmark_report_path
        @report_path = report_path
        @build_version = build_version
        @build_version.should_ignore = :ignore_revision
        @benchmark_exists = false
        @benchmark_version = BuildVersion.new("0.0.0.0", :ignore_revision)
      end

      def read_reports()
        @benchmark_report = Document.new File.read(@benchmark_report_path)
        @report = Document.new File.read(@report_path)
      end

      def setup
        @benchmark_exists = File.exist?(@benchmark_report_path)
        if @benchmark_exists then
          read_reports()
          @benchmark_version = read_benchmark_version()
        end
      end

      def validate
        if not @benchmark_exists then
          return true
        end
        values = yield @benchmark_report, @report
        benchmark_value = values[0]
        report_value = values[1]
        if benchmark_value < report_value then
          @validation_error_message = "Benchmark validation failed. Increased value from #{benchmark_value} to #{report_value}."
          return false
        end
        if @build_version > @benchmark_version then
          if report_value >= benchmark_value - 20 then
            @validation_error_message = "Benchmark validation failed. Build version (revision is ignored) has increased but the value obtained has not decreased by more than 20. #Benchmark Value: #{benchmark_value}. #Report Value: #{report_value}."
            return false
          end
        end
        return true
      end

      def update
        if !@benchmark_exists or @build_version > @benchmark_version then
          FileUtils.cp @report_path, @benchmark_report_path
          report = Document.new File.read(@benchmark_report_path)
          report.root.attributes["buildVersion"] = @build_version.to_s
          File.open(@benchmark_report_path, "w") do |file|
            report.write file
          end
        end

      end

      def validate_and_update
        setup
        validated = validate do |benchmark_report, report|
          yield benchmark_report, report
        end
        if not validated then
          raise validated.validation_error_message
        end
        update
      end

      def read_benchmark_version()
        benchmark_version = BuildVersion.new(@benchmark_report.root.attributes["buildVersion"], :ignore_revision)
        return benchmark_version
      end
    end

  end
end

