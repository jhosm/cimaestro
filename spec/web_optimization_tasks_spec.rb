require "spec_helper"

describe MinifyJavascriptTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "Dummy_cimaestro", "Release", "4.5.8.7")
    @minify = MinifyJavascriptTask.new :minify_javascript, @build_spec, NullLogger.new
    rm_r TESTS_BASE_PATH
  end

  it "should build the correct command line" do
    @project_name = ProjectType::SITE + "-Sample"
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, @project_name).
            add_path_to_working_dir(File.join(@project_name, "GeneratedJS")).
            add_file_to_project_in_working_dir(File.join(@project_name, "GeneratedJS"), "jscript1.js").
            add_file_to_project_in_working_dir(File.join(@project_name, "GeneratedJS"), "jscript2.js")

    @minify.setup
    @minify.should_receive(:sh).with(/java -jar .+compiler.jar --create_source_map=\"jscript1.js.map\" --js=".+jscript1.js" --js_output_file=".+jscript1.jsx"/)
    FileUtils.should_receive(:mv).with(/jscript1.jsx/,/jscript1.js/)
    @minify.should_receive(:sh).with(/java -jar .+compiler.jar --create_source_map=\"jscript2.js.map\" --js=".+jscript2.js" --js_output_file=".+jscript2.jsx"/)
    FileUtils.should_receive(:mv).with(/jscript2.jsx/,/jscript2.js/)
    @minify.execute
  end

  it "should not include files not present in GeneratedJS folders" do
    @project_name = ProjectType::SITE + "-Sample"
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, @project_name).
            add_path_to_working_dir(@project_name).
            add_file_to_project_in_working_dir(@project_name, "jscript1.js")

    @minify.setup
    @minify.should_not_receive(:sh)
    @minify.execute
  end

end

describe MakeVersionedFileNamesTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "Dummy_cimaestro", "Release", "4.5.8.7")
    @replace_xsl = MakeVersionedFileNamesTask.new :make_versioned_xsl_file_names, @build_spec, NullLogger.new

    @project_name = ProjectType::SITE + "-Sample"
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, @project_name).
            add_file_to_project_in_working_dir(@project_name, "teste.xsl")
  end

  it "should find all specified files to version" do
    @replace_xsl.setup
    @replace_xsl.files_to_version.length.should == 1
  end

  it "should create a file with the same name of the original, but with the version appended" do
    new_file_name = File.join(@build_spec.working_dir_path, @project_name, "4.5.8.7teste.xsl")
    rm_rf new_file_name

    @replace_xsl.setup
    @replace_xsl.execute

    File.exists?(new_file_name).should be_true
  end
end

describe ReplaceCssReferencesTask do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "DummySeveralProjectTypes_cimaestro", "Release", "1.5.8.7")
    @replace_css = ReplaceCssReferencesTask.new :make_versioned_css_file_names, @build_spec, NullLogger.new

    project_name = ProjectType::SITE + "-A_Site"
    SystemFileStructureMocker.create_working_dir_with_projects(@build_spec, project_name).
            add_file_to_project_in_working_dir(project_name, "cssfile.css").
            add_file_to_project_in_working_dir(project_name, "cssfile2.css").
            add_file_to_project_in_working_dir(project_name, "htmfile.htm", "<link src=\"cssfile.css\" rel=\"stylesheet\"/><link src=\"cssfile2.css\" rel=\"stylesheet\"/>")

    @css_referencing_files_path = File.join(@build_spec.working_dir_path, project_name)
    @build_spec.custom_specs_for(:make_versioned_css_file_names)[:css_referencing_files] = FileList[File.join(@css_referencing_files_path, "*.htm")]
  end

  it "should find all specified css referencing files to replace" do
    @replace_css.setup
    @replace_css.css_referencing_files.length.should == 1
  end

  it "should replace the css reference with the versionized name" do
    @replace_css.setup

    file_content = File.read(@replace_css.css_referencing_files[0])
    /1\.5\.8\.7cssfile\.css/.match(file_content).should == nil
    /1\.5\.8\.7cssfile2\.css/.match(file_content).should == nil
    @replace_css.execute

    file_content = File.read(@replace_css.css_referencing_files[0])
    /1\.5\.8\.7cssfile\.css/.match(file_content).should have(1).item
    /1\.5\.8\.7cssfile2\.css/.match(file_content).should have(1).item
  end
end

