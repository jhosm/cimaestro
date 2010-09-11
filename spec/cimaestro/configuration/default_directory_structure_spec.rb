require "spec_helper"

module CIMaestro
  module Configuration
    describe DefaultDirectoryStructure do
      before(:each) do
        @out = DefaultDirectoryStructure.new TESTS_BASE_PATH, "SYSTEM_NAME", "MAINLINE"
      end

      it "should build the correct standard paths" do
        @out.system_base_path.should == File.join(TESTS_BASE_PATH, "SYSTEM_NAME", "MAINLINE")
        @out.working_dir_path.should == File.join(@out.system_base_path, "Integration")
        @out.solution_dir_path.should == File.join(@out.system_base_path, "Solution")
        @out.latest_artifacts_dir_path.should == File.join(@out.system_base_path, "Artifacts", "Latest")
        @out.artifacts_dir_path.should == File.join(@out.system_base_path, "Artifacts", "Latest")
        @out.artifacts_dir_path("1.0.0.0").should == File.join(@out.system_base_path, "Artifacts", "1.0.0.0")
        @out.cimaestro_dir_path.should == File.join(@out.system_base_path, "CIMaestro")
        @out.lib_dir_path.should == File.join(@out.working_dir_path, "Lib")
        @out.logs_dir_path.should == File.join(@out.cimaestro_dir_path, "Logs")
      end
    end
  end
end

