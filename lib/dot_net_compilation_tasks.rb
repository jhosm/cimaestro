require "required_references"

module Build

  class CompileDotNetTask < Task
    include Build::ShellUtils

    attr_reader :solutions

    def initialize(rake_name, build_spec, logger)
      super(rake_name, build_spec, logger)
      @solutions = []
    end

    def setup
      if build_spec.custom_specs_for(rake_name.to_sym).has_key?(:platform)
        @platform = build_spec.custom_specs_for(rake_name.to_sym)[:platform]
      else
        @platform = "Any CPU"
      end

      if build_spec.custom_specs_for(rake_name.to_sym).has_key?(:constants)
        @constants = build_spec.custom_specs_for(rake_name.to_sym)[:constants]
      else
        @constants = build_spec.codeline.upcase
      end

      @solutions = FileList[File.join(build_spec.working_dir_path, "*VSNET*.sln")]
      @commands = @solutions.map do |solution|
        "#{Build::DOT_NET_SDK_PATH}/msbuild #{solution} /p:Configuration=#{build_spec.solution_build_config} /p:DefineConstants=#{@constants} /p:Platform=\"#{@platform}\" /t:Rebuild"
      end
    end

    def execute
      @commands.each do |cmd|
        exec_and_log(cmd)
      end

      @solutions.length
    end
  end

  class SetCommonAssemblyAttributesTask < Task
    COMMON_ASSEMBLY_INFO = "CommonAssemblyInfo.cs"

    def execute
      asm_info_path = File.join(build_spec.working_dir_path, COMMON_ASSEMBLY_INFO)
      logger.log_msg "If '#{asm_info_path}' exists, update it with common attributes."
      File.open(asm_info_path, "w") do |file|
        file.puts 'using System.Reflection;'
        file.puts
        file.puts '[assembly: AssemblyCompany("Banco BPI")]'
        file.puts "[assembly: AssemblyProduct(\"#{build_spec.system_name}\")]"
        file.puts "[assembly: AssemblyCopyright(\"Copyright  Banco BPI 2008\")]"
        file.puts
        file.puts "[assembly: AssemblyFileVersion(\"#{build_spec.version}\")]"
        file.puts "[assembly: AssemblyVersion(\"#{build_spec.version}\")]"
      end
    end
  end

  class CreateStrongNamedAssemblyPolicyTask < Task
    include Build::ShellUtils

    def setup
      @xml_policy_files = {}
      @version = BuildVersion.new(build_spec.version)

      additional_projects = []
      if build_spec.custom_specs_for(rake_name.to_sym).has_key?(:include)
        additional_projects = build_spec.custom_specs_for(rake_name.to_sym)[:include]
      end
      additional_projects.map! do |project_name|
        Project.new(File.join(build_spec.working_dir_path, project_name))
      end

      @assemblies_projects = build_spec.get_projects_of(ProjectType::GAC_ASSEMBLY)
      @assemblies_projects.push(additional_projects).flatten!.each do |project|
        xml_policy_file = <<END_OF_STRING
<configuration>
   <runtime>
      <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
       <dependentAssembly>
         <assemblyIdentity name="#{project.name}"
                           publicKeyToken="4dc65bf5a73ae936"
                           culture="neutral" />
         <bindingRedirect oldVersion="#{@version.major}.#{@version.minor}.0.0-#{@version.major}.#{@version.minor}.65535.65535"
                          newVersion="#{build_spec.version}"/>
       </dependentAssembly>
      </assemblyBinding>
   </runtime>
</configuration>
END_OF_STRING

        @xml_policy_files[project] = xml_policy_file
      end
    end

    def xml_policy_files
      @xml_policy_files
    end

    def execute
      @xml_policy_files.each_pair do |proj, policy_file|
        policy_file_path_without_extension = File.join(proj.path, "bin", build_spec.solution_build_config, "policy.#{@version.major}.#{@version.minor}.#{proj.name}")
        File.open(policy_file_path_without_extension + ".config", "w") do |file|
          file.puts policy_file
        end
        exec_and_log "#{Build::DOT_NET_2_0_SDK_PATH}/al /link:#{policy_file_path_without_extension}.config /out:#{policy_file_path_without_extension}.dll /keyfile:#{File.join(build_spec.tools_dir_path, Build::TOOLS_BUILD_DIR, "cimaestro.snk")}"
      end
    end
  end


end
