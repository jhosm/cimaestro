require "rspec/spec_helper"

describe MergeXslFilesTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "Dummy_cimaestro", "Release", "4.5.8.7")
    @merge_xsl = MergeXslFilesTask.new :merge_xsl_files, @build_spec, NullLogger.new
  end

  it "should find all specified xsl files to merge" do
    rm_rf @build_spec.working_dir_path
    fsmock = SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, ProjectType::SITE)
    project_name = fsmock.projects[0]
    fsmock.add_file_to_project_in_working_dir(project_name, "xpto.xsl")

    @merge_xsl.setup
    @merge_xsl.xsl_files.length.should == 1
  end

  it "should find only the files in buildspec.custom_specs_for(:merge_xsl)[:xsl_files], if specified" do
    fsmock = SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, ProjectType::SITE)
    project_name = fsmock.projects[0]
    fsmock.add_file_to_project_in_working_dir(project_name, "xpto.xsl").
      add_file_to_project_in_working_dir(project_name, "xpto2.xsl")

    @build_spec.custom_specs_for(:merge_xsl_files)[:xsl_files] = FileList[File.join(@build_spec.working_dir_path, project_name, "xpto.xsl")]
    @merge_xsl.setup
    @merge_xsl.xsl_files.length.should == 1
  end

  it "should not change the xsl file if there are no xsl files to include" do
    fsmock = SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, ProjectType::SITE)
    project_name = fsmock.projects[0]
    fsmock.add_file_to_project_in_working_dir(project_name, "xpto.xsl", "<xpto>teste</xpto>")

    @merge_xsl.setup
    @merge_xsl.execute

    File.read(File.join(@build_spec.working_dir_path, project_name, "xpto.xsl")).should == "<xpto>teste</xpto>"
  end

  it "should merge the inner xsl file, which itself has no includes" do
    fsmock = SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, ProjectType::SITE)
    project_name = fsmock.projects[0]
    fsmock.add_file_to_project_in_working_dir(project_name, "xpto.xsl", '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:include href="xpto2.xsl"/></xsl:stylesheet>').
      add_file_to_project_in_working_dir(project_name, "xpto2.xsl", "<xpto>teste</xpto>")

    @merge_xsl.setup
    @merge_xsl.execute

    merged_xsl = Document.new File.read(File.join(@build_spec.working_dir_path, project_name, "xpto.xsl"))
    merged_xsl.root.elements.to_a("/stylesheet/include").should == []
    merged_xsl.root.elements.to_a("/stylesheet/xpto").should_not == nil
  end

  it "should merge the inner xsl file, which itself has includes" do
    fsmock = SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, ProjectType::SITE)
       project_name = fsmock.projects[0]
       fsmock.add_file_to_project_in_working_dir(project_name, "xpto.xsl", '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:include href="xpto2.xsl"/></xsl:stylesheet>').
               add_file_to_project_in_working_dir(project_name, "xpto2.xsl", '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:include href="xpto3.xsl"/><xpto2>teste</xpto2></xsl:stylesheet>').
               add_file_to_project_in_working_dir(project_name, "xpto3.xsl", "<xpto3>teste</xpto3>")

    @merge_xsl.setup
    @merge_xsl.execute

    outermost_xsl = Document.new File.read(File.join(@build_spec.working_dir_path, project_name, "xpto.xsl"))
    outermost_xsl.root.elements.to_a("/stylesheet/include").should == []
    outermost_xsl.root.elements.to_a("/stylesheet/xpto3").should_not == nil
    outermost_xsl.root.elements.to_a("/stylesheet/xpto2").should_not == nil
  end
end

describe ValidateAndMinimizeXmlFilesTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "Dummy_cimaestro", "Release", "4.5.8.7")
    @validate_xml = ValidateAndMinimizeXmlFilesTask.new :validate_xml, @build_spec, NullLogger.new
  end

  it "should find all files and all should be well formed" do
    project_name = ProjectType::WINDOWS_SERVICE + "-ValidateAndMinimizeXmlFilesTask"
    rm_rf @build_spec.working_dir_path
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, project_name).
            add_file_to_project_in_working_dir(project_name, "test.xml", "<xml> </xml>")
    @validate_xml.setup
    @validate_xml.xml_files.length.should == 1
    lambda { @validate_xml.execute }.should_not raise_error
  end

  it "should find when one of the xml files is not well formed" do
    @validate_xml.setup
    File.open(@validate_xml.xml_files[0], "w") do |file|
      file.puts "<garbage>"
    end
    lambda { @validate_xml.execute }.should raise_error
    rm @validate_xml.xml_files[0]
  end

  it "should minimize the files, by stripping all characters between tags" do
    project_name = ProjectType::WINDOWS_SERVICE + "-Sample"
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, project_name).
            add_file_to_project_in_working_dir(project_name, "xml-bem-formado.xml", "<teste> <ola/></teste>")

    @validate_xml.setup
    @validate_xml.execute
    File.read(File.join(@build_spec.working_dir_path, project_name, "xml-bem-formado.xml")).should == "<teste><ola/></teste>"
  end
end

