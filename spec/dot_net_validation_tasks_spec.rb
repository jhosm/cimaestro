require "spec_helper"

describe AnalyzeCodeTask do
  
  before(:each) do
    @task, @build_spec = create_task(AnalyzeCodeTask)
    @task.src_control = mock("src_control", :null_object => true)
    @task.stub!(:sh)
    @task.setup
    SystemFileStructureMocker.create_with_projects(@build_spec, []).add_build_dir
    cp File.join(TESTS_SOURCE_FILES, "24-issues-report-fxcop.xml"), @task.benchmark_report_path, :verbose=>true
  end

  it "should create a benchmark file if it does not exist" do
    cp File.join(TESTS_SOURCE_FILES, "0-issues-report-fxcop.xml"), @task.report_path, :verbose=>true
    File.should_receive(:exist?).any_number_of_times.and_return(false)
    FileUtils.should_receive(:cp).with(/report-fxcop.xml/,@task.benchmark_report_path)
    @task.src_control.should_receive(:add).with(/benchmark-report-fxcop.xml/)
    @task.src_control.should_receive(:commit)
    @task.execute
  end

  it "should add the build version to the benchmark report, when creating a new one" do
    cp File.join(TESTS_SOURCE_FILES, "0-issues-report-fxcop.xml"), @task.report_path, :verbose=>true
    rm_r @task.benchmark_report_path

    @task.execute

    report = Document.new File.read(@task.benchmark_report_path)
    report.root.attributes["buildVersion"].should == BuildVersion.new(@build_spec.version).to_s
  end

  it "should fail if the number of issues has increased within the same major.minor version" do
    cp File.join(TESTS_SOURCE_FILES, "25-issues-report-fxcop.xml"), @task.report_path, :verbose=>true
    lambda {@task.execute}.should raise_error
  end

  it "should not fail if the number of issues has not increased within the same major.minor version" do
    cp File.join(TESTS_SOURCE_FILES, "24-issues-report-fxcop.xml"), @task.report_path, :verbose=>true
    @task.execute
  end

  it "should fail if the number of issues has not decreased by more than twenty when a version increases" do
    @build_spec.version = "1.5.9.0"
    cp File.join(TESTS_SOURCE_FILES, "4-issues-report-fxcop.xml"), @task.report_path, :verbose=>true
    lambda {@task.execute}.should raise_error
  end

  it "should not fail if the number of issues is zero, regardless of versions" do
    cp File.join(TESTS_SOURCE_FILES, "0-issues-report-fxcop.xml"), @task.report_path, :verbose=>true
    @task.execute
  end

  it "should not fail if the number of issues decreased by more than twenty when a version increases" do
    @build_spec.version = "2.0.0.0"
    cp File.join(TESTS_SOURCE_FILES, "3-issues-report-fxcop.xml"), @task.report_path, :verbose=>true
    @task.execute
  end

  it "should update the benchmark report when the analysis passes and the version has increased" do
    @build_spec.version = "1.6.0.0"
    @task.execute
    report = Document.new File.read(@task.benchmark_report_path)
    report.root.attributes["buildVersion"].should == "1.6.0.0"
  end

  it "should not update the benchmark report when the analysis passes and only the version revision has changed" do
    @build_spec.version = "1.5.8.9"
    @task.execute
    report = Document.new File.read(@task.benchmark_report_path)
    report.root.attributes["buildVersion"].should == "1.5.8.7"
  end
end

describe RunDotNetUnitTestsTask do
  before(:each) do
    @tests, @build_spec = create_task(RunDotNetUnitTestsTask)
  end

  it "should build command line correctly when two test projects are present" do
    SystemFileStructureMocker.mock_working_dir_with_projects(@build_spec, [
            ProjectType::UNIT_TEST + "-DummyAssembly.Tests",
                    ProjectType::UNIT_TEST + "-DummyAssembly2.Tests",
                    ProjectType::ASSEMBLY + "-DummyAssembly"]
    )

    @tests.setup

    unit_tests_projects = @build_spec.get_projects_of(ProjectType::UNIT_TEST)
    @tests.command_line.should == "\"#{TESTS_BASE_PATH}/../_Tools/PartCover/PartCover\" " +
            "--target=#{TESTS_BASE_PATH}/../_Tools/NUnit/bin/nunit-console.exe " +
            "--target-args=\"" +
            File.join(unit_tests_projects[0].path, "bin", "Release", "DummyAssembly.Tests.dll") +  " " +
            File.join(unit_tests_projects[1].path, "bin", "Release", "DummyAssembly2.Tests.dll") + " " +
            "/xml:" + @build_spec.logs_dir_path + "/tests-results.xml" +
            "\" " +
            "--include=[DummyAssembly]* " +
            "--exclude=[DummyAssembly.Tests]* " +
            "--exclude=[DummyAssembly2.Tests]* " +
            "--output=" + @build_spec.logs_dir_path + "/code-coverage-results.xml"
  end

  it "should ensure that the logs dir is created before running the tests" do
    SystemFileStructureMocker.mock_working_dir_with_projects(@build_spec, [
            ProjectType::UNIT_TEST + "-DummyAssembly.Tests"
    ])
    @tests.stub!(:sh).and_yield(true, 0)
    File.should_receive(:read).with(/tests-results.xml/).and_return("<dummy/>")
    @tests.setup

    rm_rf @build_spec.logs_dir_path
    @tests.execute
    File.exist?(@build_spec.logs_dir_path).should be_true
  end

  it "should not fail when there are no tests" do
    @build_spec.get_projects_of(ProjectType::UNIT_TEST).each do |p|
      FileUtils.rm_r(p.path)
    end
    @tests.execute
  end

  it "should break the build if a test fails" do
    SystemFileStructureMocker.mock_working_dir_with_projects(@build_spec, [
            ProjectType::UNIT_TEST + "-DummyAssembly.Tests"
    ])
    @tests.stub!(:sh).and_yield(true, 0)
    File.should_receive(:read).with(/tests-results.xml/).and_return("<dummy><failure/></dummy>")
    @tests.setup
    lambda {@tests.execute}.should raise_error
  end
end

