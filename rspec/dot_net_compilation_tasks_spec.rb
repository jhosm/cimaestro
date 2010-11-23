require "rspec/spec_helper"

describe CompileDotNetTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "Dummy_cimaestro", "Release", "4.5.8.7")
    @compile = CompileDotNetTask.new :compile_dot_net_solutions, @build_spec, NullLogger.new
    rm_rf @build_spec.working_dir_path
  end

  it "should find a solution to compile" do
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, []).
            add_file_to_working_dir("SAMPLE-VSNET2008.sln")
    @compile.setup
    @compile.solutions.length.should == 1
  end

  it "should find two solutions to compile" do
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, []).
            add_file_to_working_dir("SAMPLE-VSNET2008.sln").
            add_file_to_working_dir("SAMPLE-VSNET2005.sln")
    @compile.setup
    @compile.solutions.length.should == 2
  end

  it "should not do a build when it doesn't find solutions" do
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, [])
    @compile.setup
    result = @compile.execute
    result.should == 0
  end

  it "should do a solution build" do
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, []).
                add_file_to_working_dir("SAMPLE-VSNET2008.sln")
    @compile.setup
    @compile.should_receive(:sh).with(/.+\/msbuild .+SAMPLE-VSNET2008.sln \/p:Configuration=Release \/p:DefineConstants=RELEASE \/p:Platform=\"Any CPU\" \/t:Rebuild/)
    @compile.execute
  end

  it "should do two solution builds when there are two solution files" do
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, []).
                add_file_to_working_dir("SAMPLE-VSNET2008.sln").
                add_file_to_working_dir("ANOTHERSAMPLE-VSNET2005.sln")
    @compile.setup
    @compile.should_receive(:sh).twice.with(/.+\/msbuild .+SAMPLE-VSNET\d{4}.sln \/p:Configuration=Release \/p:DefineConstants=RELEASE \/p:Platform=\"Any CPU\" \/t:Rebuild/)
    @compile.execute
  end
end

describe SetCommonAssemblyAttributesTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "Dummy_cimaestro", "Release", "4.5.6.7")
    @common_attr_task = SetCommonAssemblyAttributesTask.new :common_attributes, @build_spec, NullLogger.new
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, ProjectType::ASSEMBLY + "-Sample")
    @common_attr_task.setup
  end

  it "should set common solution attributes for all assemblies" do
    common_assembly_info = <<END_OF_STRING
using System.Reflection;

[assembly: AssemblyCompany("Banco BPI")]
[assembly: AssemblyProduct("Dummy_cimaestro")]
[assembly: AssemblyCopyright("Copyright  Banco BPI 2008")]

[assembly: AssemblyFileVersion("4.5.6.7")]
[assembly: AssemblyVersion("4.5.6.7")]
END_OF_STRING

    @common_attr_task.execute
    File.read(@build_spec.working_dir_path + "/CommonAssemblyInfo.cs" ).should == common_assembly_info
  end
end

describe CreateStrongNamedAssemblyPolicyTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "Dummy_cimaestro", "Release", "4.5.6.7")
    @task = CreateStrongNamedAssemblyPolicyTask.new :common_attributes, @build_spec, NullLogger.new
    @task.setup
  end

  it "should do nothing if there aren't strong named assemblies" do
    @task.setup
    @task.should_not_receive(:sh)
    @task.execute
  end

  it "should generate xml policy file when there is a strong named assembly" do
    FileList.stub!(:new).and_return([File.join(@build_spec.working_dir_path, "GAC-MyStrongNamedAssembly")])
    @task.setup
    @task.xml_policy_files.size.should == 1
    assembly = Document.new(@task.xml_policy_files[@task.xml_policy_files.keys()[0]]).elements.to_a("/configuration/runtime/assemblyBinding/dependentAssembly")
    assembly.length.should == 1
    assembly_identity = assembly[0].get_elements("assemblyIdentity")
    assembly_identity.length.should == 1
    assembly_identity[0].attribute("name").value.should == "MyStrongNamedAssembly"

    binding_redirect = assembly[0].get_elements("bindingRedirect")
    binding_redirect.length.should == 1
    binding_redirect[0].attribute("oldVersion").value.should == "4.5.0.0-4.5.65535.65535"
    binding_redirect[0].attribute("newVersion").value.should == "4.5.6.7"

  end

  it "should generate more than one xml policy file when there are two or more strong named assemblies" do
    FileList.stub!(:new).and_return([File.join(@build_spec.working_dir_path, "GAC-MyStrongNamedAssembly"), File.join(@build_spec.working_dir_path, "GAC-MyStrongNamedAssembly2")])
    @task.setup
    @task.xml_policy_files.size.should == 2
    @task.xml_policy_files.each_pair do |project, policy_file|
      assembly = Document.new(policy_file).elements.to_a("/configuration/runtime/assemblyBinding/dependentAssembly")
      assembly_identity = assembly[0].get_elements("assemblyIdentity")
      assembly_identity[0].attribute("name").value.should == project.name
    end
  end

  it "should save policy file" do
    FileList.stub!(:new).and_return([File.join(@build_spec.working_dir_path, "GAC-MyStrongNamedAssembly")])
    @task.setup

    file = mock("config_file")
    file.should_receive(:puts).with(@task.xml_policy_files[@task.xml_policy_files.keys()[0]]).once
    File.stub!(:open)
    File.should_receive(:open).with(/.+policy\.4\.5\.MyStrongNamedAssembly.config$/, "w").and_yield(file)
    @task.stub!(:sh)
    @task.execute
  end

  it "should call al" do
    FileList.stub!(:new).and_return([File.join(@build_spec.working_dir_path, "GAC-MyStrongNamedAssembly")])
    @task.setup

    file = mock("config_file", :null_object => true)
    File.stub!(:open)
    @task.should_receive(:sh).
            with(/.+al \/link:.+policy.4.5.MyStrongNamedAssembly.config \/out:.+policy.4.5.MyStrongNamedAssembly.dll \/keyfile:.+cimaestro\.snk/).
            once

    @task.execute
  end

end
