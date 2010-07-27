require "spec_helper"

describe GetSvnSourcesTask do
  before(:each) do
    @task, @build_spec = create_task(GetSvnSourcesTask)
  end

  it "should checkout" do
    @task.src_control.should_receive(:checkout)
    @task.execute
  end
end

describe GetLocalSourcesTask do
  before(:each) do
    @get_sources, @build_spec = create_task(GetLocalSourcesTask)
  end

  it "should get sources from local solution" do
    SystemFileStructureMocker.create_solution_with_projects(@build_spec, [ProjectType::WINDOWS_SERVICE + "-Sample"])
    FileUtils.rm_rf(@build_spec.working_dir_path)
    @get_sources.execute
    File.exist?(@build_spec.working_dir_path).should be_true
  end
end
