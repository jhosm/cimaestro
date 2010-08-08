require "spec_helper"

describe CIMaestro::SourceControl::Svn do
  before(:each) do
    @svn = SourceControlFactory.create("c:/local", "http://xpto")
    @svn.stub!(:sh)
  end

  it "should update" do
    @svn.update
    @svn.last_command.should == "svn update \"c:/local\""
  end

  it "should commit" do
    @svn.commit("mensagem")
    @svn.last_command.should == "svn commit --message \"mensagem\" \"c:/local\""
  end

  it "should add" do
    @svn.add("folder_or_file")
    @svn.last_command.should == "svn add --force \"c:/local/folder_or_file\""
  end

  it "should delete" do
    @svn.delete("folder_or_file")
    @svn.last_command.should == "svn delete \"c:/local/folder_or_file\""
  end

  it "should checkout" do
    @svn.checkout()
    @svn.last_command.should == "svn co \"http://xpto\" \"c:/local\""
  end
end