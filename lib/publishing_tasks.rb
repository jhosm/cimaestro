module Build

  class AbstractPublishTask < Task
    def initialize(rake_name, build_spec, logger)
      super(rake_name, build_spec, logger)
      @artifacts = {}
    end

    def execute
      FileUtils.mkpath(build_spec.latest_artifacts_dir_path)

      @artifacts.each_value do |artifact|
        artifact.each do |src, dst|
          logger.log_msg( "Source:' #{src}'.")
          logger.log_msg( "Destination:' #{dst}'.")
          if File.exist?(src)
            src = File.join(src, ".") if !File.file?(src)
            FileUtils.mkpath dst if !File.file?(dst)
            FileUtils.cp_r src, dst, :verbose => true
          else
            logger.log_msg( "Source '#{src}' does not exist.")
          end
        end
      end
    end
  end

  class PublishTask < AbstractPublishTask
    def initialize(rake_name, build_spec, logger)
      super(rake_name, build_spec, logger)
    end

    def setup
      setup_windows_services
      setup_gac_assemblies
      setup_sites
      setup_activities_assemblies
    end

    protected

    def setup_windows_services
      src_dst = {}
      build_spec.get_projects_of(ProjectType::WINDOWS_SERVICE).each do |proj|
        src_dst[File.join(proj.path, "bin", build_spec.solution_build_config)] = File.join(build_spec.latest_artifacts_dir_path, File.basename(proj.path))
      end
      @artifacts[ProjectType::WINDOWS_SERVICE] = src_dst
    end

    def setup_gac_assemblies
      src_dst = {}
      build_spec.get_projects_of(ProjectType::GAC_ASSEMBLY).each do |proj|
        src_dst[File.join(proj.path, "bin", build_spec.solution_build_config)] = File.join(build_spec.latest_artifacts_dir_path, ProjectType::GAC_ASSEMBLY, proj.name)
      end
      @artifacts[ProjectType::GAC_ASSEMBLY] = src_dst
    end

    def setup_sites
      src_dst = {}
      build_spec.get_projects_of([ProjectType::SITE, ProjectType::WEB_SERVICE, ProjectType::WCF_SITE]).each do |proj|
        if File.exists?(File.join(build_spec.working_dir_path, "PrecompiledWeb", File.basename(proj.path))) then
          src_dst[File.join(build_spec.working_dir_path, "PrecompiledWeb", File.basename(proj.path))] = File.join(build_spec.latest_artifacts_dir_path, File.basename(proj.path))
        else
          src_dst[File.join(build_spec.working_dir_path, File.basename(proj.path))] = File.join(build_spec.latest_artifacts_dir_path, File.basename(proj.path))
        end
      end
      @artifacts[ProjectType::SITE] = src_dst
    end

    def setup_activities_assemblies
      src_dst = {}
      build_spec.get_projects_of([ProjectType::ACTIVITIES_ASSEMBLY]).each do |proj|
        src_dst[File.join(proj.path, "bin", build_spec.solution_build_config)] = File.join(build_spec.latest_artifacts_dir_path, ProjectType::ACTIVITIES_ASSEMBLY, proj.name)
      end
      @artifacts[ProjectType::ACTIVITIES_ASSEMBLY] = src_dst
    end

    public

    def execute
      FileUtils.rm_r build_spec.latest_artifacts_dir_path if File.exist?(build_spec.latest_artifacts_dir_path)

      super

      del_svn( build_spec.latest_artifacts_dir_path ) if @artifacts.length > 0
    end

    protected

    def get_dir(d)
      Dir.new(d).grep(/[^\.]/).collect do |f|
        File.join(d, f)
      end
    end

    def del_dir(d)
      get_dir(d).each do |filename|
        if File.directory?(filename)
          del_dir(filename)
        else
          File.unlink(filename)
        end
      end
      Dir.delete(d)
    end

    def del_svn(path='')
      get_dir(path).find_all do |filename|
        if File.directory?(filename)
          if File.basename(filename) == '.svn'
            puts "delete #{filename}"
            del_dir( filename )
          else
            del_svn( filename )
          end
        end
      end
    end
  end

  class VersionSitesTask < Task
    attr_reader :sites

    def setup
      @sites = build_spec.get_projects_of(ProjectType::SITE)
    end

    def execute
      @sites.each do | site |
        File.open(File.join(site.path, "version.htm"), "w") do |file|
          file.puts "Version: " + build_spec.version.to_s
          file.puts "Date: " + Time.now.to_s
        end
      end
      @sites.each do | site |
        File.open(File.join(site.path, "buildVersion.js"), "w") do |file|
          file.puts 'var BUILD_VERSION = "' + build_spec.version.to_s + '";'
        end
      end
    end
  end
end