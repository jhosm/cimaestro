require "spec_helper"

module CIMaestro
  module Configuration

    describe BuildSpec do
      before(:each) do
        conf = BuildConfig.load
        conf.source_control.repository_path = conf.directory_structure.new("", "Dummy_cimaestro", "Release").solution_dir_path
        @build_spec = BuildSpec.new( '../../../..', "Dummy_cimaestro", "Release", "4.5.8.7", conf)
      end

      it "should build working_dir_path from base_path, system_name and codeline" do
        @build_spec.working_dir_path.should == "../../../../Dummy_cimaestro/Release/Integration"
      end

      it "should find all directories of a specified project type" do
        SystemFileStructureMocker.mock_working_dir_with_projects(@build_spec, [
                ProjectType::UNIT_TEST,
                ProjectType::UNIT_TEST,
                ProjectType::ASSEMBLY]
        )

        unit_tests_projects = @build_spec.get_projects_of(ProjectType::UNIT_TEST)
        unit_tests_projects.length.should == 2
        unit_tests_projects.all? { |p| p.type == ProjectType::UNIT_TEST }.should be_true

        assembly_projects = @build_spec.get_projects_of(ProjectType::ASSEMBLY)
        assembly_projects.length.should == 1
        assembly_projects.all? { |p| p.type == ProjectType::ASSEMBLY }.should be_true
      end

      it "should find all directories of the specified project types" do
        SystemFileStructureMocker.mock_working_dir_with_projects(@build_spec, [
                ProjectType::UNIT_TEST,
                ProjectType::UNIT_TEST,
                ProjectType::ASSEMBLY]
        )

        projects = @build_spec.get_projects_of([ProjectType::UNIT_TEST, ProjectType::ASSEMBLY])
        projects.length.should == 3
        projects.all? { |p| p.type == ProjectType::UNIT_TEST || p.type == ProjectType::ASSEMBLY }.should be_true
      end

      it "should extract the project path from a project's file path" do
        file_path = "../../../../Dummy_cimaestro/Release/Integration/Site-Xpto/teste/teste.xml"
        @build_spec.extract_project_path(file_path).should == "../../../../Dummy_cimaestro/Release/Integration/Site-Xpto"
      end

      it "should find all the files from specified type in specified projects" do
        site1 = ProjectType::SITE + "-Sample1"
        site2 = ProjectType::SITE + "-Sample2"
        assembly1 = ProjectType::ASSEMBLY + "-Sample2"
        SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, [site1, site2, assembly1]).
                add_file_to_project_in_working_dir(site1, "script1.js").
                add_file_to_project_in_working_dir(site2, "script2.js").
                add_file_to_project_in_working_dir(assembly1, "script3.js")

        projects = @build_spec.get_projects_of([ProjectType::SITE])
        file_list = @build_spec.get_file_list(["js"], "", "", projects)
        file_list.length.should == 2
        file_list.grep(/script1/).length.should == 1
        file_list.grep(/script2/).length.should == 1
      end

      it "is true that the local path for a source control is always the working dir" do
        conf = BuildConfig.load
        conf.source_control.repository_path = conf.directory_structure.new("", "Dummy_cimaestro", "Release").solution_dir_path


        fs_build_spec = BuildSpec.new( '../../../..', "Dummy_cimaestro", "Release", "4.5.8.7", conf)
        fs_build_spec.src_control.local_path.should == @build_spec.working_dir_path

        conf.source_control.type = SourceControl::Svn
        conf.source_control.repository_path = "http://local"
        svn_build_spec = BuildSpec.new( '../../../..', "Dummy_cimaestro", "Release", "4.5.8.7", conf)
        svn_build_spec.src_control.local_path.should == @build_spec.working_dir_path

      end

    end

    describe BuildVersion do
      it "should allow comparisons" do
        BuildVersion.new("1.0.0.0").should == BuildVersion.new("1.0.0.0")
        BuildVersion.new("1.0.0.0").should_not == BuildVersion.new("2.0.0.0")

        (BuildVersion.new("1.0.0.0") != BuildVersion.new("1.0.0.0")).should be_false
        (BuildVersion.new("1.0.0.0") != BuildVersion.new("2.0.0.0")).should be_true

        (BuildVersion.new("1.0.0.0") > BuildVersion.new("1.0.0.1")).should be_false
        (BuildVersion.new("1.0.0.0") > BuildVersion.new("1.0.1.0")).should be_false
        (BuildVersion.new("1.0.0.0") > BuildVersion.new("1.1.0.0")).should be_false
        (BuildVersion.new("1.0.0.0") > BuildVersion.new("2.0.0.0")).should be_false
        (BuildVersion.new("1.0.0.0") > BuildVersion.new("1.0.0.0")).should be_false
        (BuildVersion.new("1.0.0.1") > BuildVersion.new("1.0.0.0")).should be_true
        (BuildVersion.new("1.0.1.0") > BuildVersion.new("1.0.0.0")).should be_true
        (BuildVersion.new("1.1.0.0") > BuildVersion.new("1.0.0.0")).should be_true
        (BuildVersion.new("2.0.0.0") > BuildVersion.new("1.0.0.0")).should be_true

        (BuildVersion.new("1.0.0.0") >= BuildVersion.new("1.0.0.1")).should be_false
        (BuildVersion.new("1.0.0.0") >= BuildVersion.new("1.0.0.0")).should be_true
        (BuildVersion.new("2.0.0.0") >= BuildVersion.new("1.0.0.0")).should be_true

        (BuildVersion.new("1.0.0.0") < BuildVersion.new("1.0.0.1")).should be_true
        (BuildVersion.new("1.0.0.0") < BuildVersion.new("1.0.1.0")).should be_true
        (BuildVersion.new("1.0.0.0") < BuildVersion.new("1.1.0.0")).should be_true
        (BuildVersion.new("1.0.0.0") < BuildVersion.new("2.0.0.0")).should be_true
        (BuildVersion.new("1.0.0.0") < BuildVersion.new("1.0.0.0")).should be_false
        (BuildVersion.new("1.0.0.1") < BuildVersion.new("1.0.0.0")).should be_false
        (BuildVersion.new("1.0.1.0") < BuildVersion.new("1.0.0.0")).should be_false
        (BuildVersion.new("1.1.0.0") < BuildVersion.new("1.0.0.0")).should be_false
        (BuildVersion.new("2.0.0.0") < BuildVersion.new("1.0.0.0")).should be_false

        (BuildVersion.new("1.0.0.0") <= BuildVersion.new("1.0.0.1")).should be_true
        (BuildVersion.new("1.0.0.0") <= BuildVersion.new("1.0.0.0")).should be_true
        (BuildVersion.new("2.0.0.0") <= BuildVersion.new("1.0.0.0")).should be_false
      end

      it "should ignore revision in comparisons, if it is told to" do
        BuildVersion.new("1.0.0.0", :ignore_revision).should == BuildVersion.new("1.0.0.1", :ignore_revision)

        (BuildVersion.new("1.0.0.0", :ignore_revision) != BuildVersion.new("1.0.0.1", :ignore_revision)).should be_false

        (BuildVersion.new("1.0.0.1", :ignore_revision) > BuildVersion.new("1.0.0.0", :ignore_revision)).should be_false

        (BuildVersion.new("1.0.0.1", :ignore_revision) >= BuildVersion.new("1.0.0.0", :ignore_revision)).should be_true

        (BuildVersion.new("1.0.0.0", :ignore_revision) < BuildVersion.new("1.0.0.1", :ignore_revision)).should be_false

        (BuildVersion.new("1.0.0.0", :ignore_revision) <= BuildVersion.new("1.0.0.1", :ignore_revision)).should be_true
      end
    end
  end
end