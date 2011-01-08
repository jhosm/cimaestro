class SystemFileStructureMocker
  attr_reader :projects
  
  def initialize(build_spec)
    @build_spec = build_spec
    @projects = []
    @@prj_index = 0
  end

  def add_build_scripts_dir()
    mkpath @build_spec.build_scripts_dir_path
    self
  end

  def add_logs_dir()
    mkpath @build_spec.logs_dir_path
    self
  end

  def add_project(project_name)
    if project_name.include?("-")
      @projects<<project_name
    else
      @projects<<project_name + "-" + @@prj_index.to_s
      @@prj_index+=1
    end
    self
  end

  def add_file_to_project_in_working_dir(project_name, file_name, contents = "")
    File.open(File.join(@build_spec.working_dir_path, project_name, file_name), "w") do |file|
      file.write contents
    end
    self
  end

  def add_file_to_working_dir(file_name, contents = "")
    File.open(File.join(@build_spec.working_dir_path, file_name), "w") do |file|
      file.write contents
    end
    self
  end

  def add_path_to_working_dir(path)
    FileUtils.mkpath(File.join(@build_spec.working_dir_path, path))
    self
  end

  def add_file_to_path(path, file_name, contents ="")
    File.open(File.join(@build_spec.working_dir_path, path, file_name), "w") do |file|
      file.write contents
    end
    self
  end

  def mock_working_dir
    @projects.group_by { |project| project.split("-")[0] }.each do |project_type, projects|
      projects_paths = projects.map { | project | File.join(@build_spec.working_dir_path, project) }
      FileList.stub!(:[]).and_return([])
      FileList.should_receive(:[]).
              any_number_of_times.
              with(File.join(@build_spec.working_dir_path, project_type + "*")).
              and_return(projects_paths)
    end
  end

  def create_solution
    create @build_spec.solution_dir_path
  end

  def create_working_dir
    create @build_spec.working_dir_path
  end

  def create(base_dir)
    verbose(false) do
      mkpath File.expand_path(base_dir) unless File.exist? base_dir
      @projects.each do |project_name|
        mkdir File.join(base_dir, project_name) unless File.exist? File.join(base_dir, project_name)
      end
    end
  end

  def SystemFileStructureMocker.mock_working_dir_with_projects(build_spec, projects)
    result = SystemFileStructureMocker.new(build_spec)
    projects.each {|project| result.add_project(project) }
    result.mock_working_dir
    result
  end

  def SystemFileStructureMocker.create_solution_with_projects(build_spec, projects)
    SystemFileStructureMocker.create_with_projects(build_spec, projects) {|result|result.create_solution}
  end

  def SystemFileStructureMocker.create_working_dir_with_projects(build_spec, projects)
    SystemFileStructureMocker.create_with_projects(build_spec, projects) {|result|result.create_working_dir}
  end

  def SystemFileStructureMocker.create_with_projects(build_spec, projects)
    result = SystemFileStructureMocker.new(build_spec)
    projects.each {|project| result.add_project(project) }
    yield result if block_given? 
    result
  end
end

module Enumerable
  def group_by
    assoc = {}

    each do |element|
      key = yield(element)

      if assoc.has_key?(key)
        assoc[key] << element
      else
        assoc[key] = [element]
      end
    end

    assoc
  end
end