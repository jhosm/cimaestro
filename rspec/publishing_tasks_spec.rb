require "rspec/spec_helper"

describe AbstractPublishTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "ExampleSystem", "Release", "4.5.8.7")
    @publish = AbstractPublishTask.new :publish, @build_spec, NullLogger.new
  end

  it "should create Latest Artifacts directory" do
    FileUtils.should_receive(:mkpath).with(@build_spec.latest_artifacts_dir_path)
    @publish.execute
  end
end

describe PublishTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "ExampleSystem", "Release", "4.5.8.7")
    @publish = PublishTask.new :publish, @build_spec, NullLogger.new
  end

  it "should re-create Latest Artifacts directory, if already exists" do

    File.should_receive(:exist?).with(@build_spec.latest_artifacts_dir_path).and_return(true)
    FileUtils.should_receive(:rm_r).with(@build_spec.latest_artifacts_dir_path)
    FileUtils.should_receive(:mkpath).with(@build_spec.latest_artifacts_dir_path)
    @publish.execute
  end

  it "should not fail if one of the specified source files does not exist" do

    project_with_missing_sources = ProjectType::WINDOWS_SERVICE + "-Sample"
    SystemFileStructureMocker.mock_working_dir_with_projects(@build_spec, [project_with_missing_sources])
    @publish.setup

    File.stub!(:exist?).and_return(true)
    FileUtils.stub!(:rm_r)
    #Quando for verificar se o binario do projecto existe, vou dizer que nao.
    File.should_receive(:exist?).
            with(File.join(@build_spec.working_dir_path, project_with_missing_sources, "bin", @build_spec.solution_build_config)).
            and_return(false)
    lambda { @publish.execute }.should_not raise_error
  end

  it "should copy artifacts to Latest Artifacts directory" do
    project_name = ProjectType::WINDOWS_SERVICE + "-Sample"
    SystemFileStructureMocker.mock_working_dir_with_projects(@build_spec, [project_name])
    @publish.setup

    File.stub!(:exist?).and_return(true)
    FileUtils.should_receive(:cp_r)
    @publish.execute
  end
end

describe VersionSitesTask do
  before(:each) do
    @build_spec = BuildSpec.new('../../../..', "DummySeveralProjectTypes_cimaestro", "Release", "4.5.8.7")
    @version = VersionSitesTask.new :publish, @build_spec, NullLogger.new
  end

  it "should create a version.htm on thr root of the site, containing version and build date" do
    @version.setup
    @version.execute

    version_file_contents = /Version: 4.5.8.7\nDate: .*/

    @build_spec.get_projects_of(ProjectType::SITE).each do | project |
      File.read(File.join(project.path, "buildVersion.htm")).match(version_file_contents).should_not == nil
    end
  end

  it "should create a version.js on thr root of the site, containing the build version" do
    @version.setup
    @version.execute

    version_file_contents = /var BUILD_VERSION = "4.5.8.7";/

    @build_spec.get_projects_of(ProjectType::SITE).each do | project |
      File.read(File.join(project.path, "buildVersion.js")).match(version_file_contents).should_not == nil
    end
  end
end