require "rspec/spec_helper"

module CIMaestro
  module SourceControl
    describe FileSystem do
      it "should get sources from local file system" do
        fs = FileSystem.new("c:/local", "c:/repository")

        fs.should_receive(:sh).with(/attrib -R c:\/local\/\*\.\* \/S.*/)
        FileUtils.should_receive(:cp_r).with("c:/repository/.", "c:/local")

        fs.checkout
      end

    end
  end
end