require "rspec/spec_helper"

describe NAntCompatibleXmlLogger do
  before(:each) do
    @build_spec = BuildSpec.new(TESTS_BASE_PATH, "Dummy_cimaestro", "Release", "4.5.8.7")
    @log = NAntCompatibleXmlLogger.new "Mr Build", File.join(@build_spec.logs_dir_path, "build-results.xml")
  end

  it "should create an empty document with the name of the system_name being built" do
    @log.current_log.elements.to_a("/buildresults[@project='Mr Build']/duration[text()=0]").length.should == 1
  end

  it "should create a node when the current task does not exist" do
    @log.set_current_task("my_task")
    @log.current_log.elements.to_a("/buildresults[@project='Mr Build']/target[@name='my_task']/task[@name='my_task']").length.should == 1
  end

  it "should not create a node when the current task already exists" do
    @log.set_current_task("my_task")
    @log.set_current_task("my_task")
    @log.current_log.elements.to_a("//task[@name='my_task']").length.should == 1
  end

  it "should add a message to the current task" do
    @log.set_current_task("my_task")
    @log.log_msg("Aqui estou eu")
    message_XPath = "//task[@name='my_task']/message[@level='Info']"
    @log.current_log.elements.to_a(message_XPath).length.should == 1
    @log.current_log.elements.to_a(message_XPath )[0].text.should == "Aqui estou eu"
  end

  it "should split a message with new lines into several messages, one for each line" do
    @log.set_current_task("my_task")
    @log.log_msg("Aqui estou eu\nAqui esta nova linha")
    message_xpath = "//task[@name='my_task']/message[@level='Info']"
    @log.current_log.elements.to_a(message_xpath).length.should == 2
    @log.current_log.elements.to_a(message_xpath)[0].text.should == "Aqui estou eu"
    @log.current_log.elements.to_a(message_xpath)[1].text.should == "Aqui esta nova linha"
  end

  it "should fail if it tries to add a message without a current task" do
    lambda { @log.log_msg("Aqui estou eu") }.should raise_error
  end

  it "should add the task's duration" do
    @log.set_current_task("my_task")
    @log.log_duration(343.2)

    @log.current_log.elements.to_a("//task[@name='my_task']/duration[text()=343200]").length.should == 1
    @log.current_log.elements.to_a("//target[@name='my_task']/duration[text()=343200]").length.should == 1
    @log.current_log.elements.to_a("/buildresults[@project='Mr Build']/duration[text()=343200]").length.should == 1
  end

  it "should fail if the given task duration is not a number" do
    @log.set_current_task("my_task")
    lambda { @log.log_duration("") }.should raise_error(ArgumentError)
  end

  it "should fail if it tries to log duration without a current task" do
    lambda { @log.log_duration(343.2) }.should raise_error("You must set a current task first.")
  end

  it "should update the build duration when a task's duration is logged" do
    @log.set_current_task("my_task")
    @log.log_duration(1.0)
    @log.set_current_task("my_task2")
    @log.log_duration(2.0)

    @log.current_log.elements.to_a("//task[@name='my_task']/duration[text()=1000]").length.should == 1
    @log.current_log.elements.to_a("//task[@name='my_task2']/duration[text()=2000]").length.should == 1
    @log.current_log.elements.to_a("/buildresults[@project='Mr Build']/duration[text()=3000]").length.should == 1
  end

  it "should add a failure node when an error is logged" do
    @log.log_error("Isto e um erro")
    error_message_XPath = "/buildresults[@project='Mr Build']/failure/builderror/message[@level='Error']"
    @log.current_log.elements.to_a(error_message_XPath).length.should == 1
    @log.current_log.elements.to_a(error_message_XPath)[0].text.should == "Isto e um erro"
  end

  it "should write the log to a file in the system_name's log dir" do
    log_path = File.join(@build_spec.logs_dir_path, "build-results.xml")
    rm(log_path, :force => true)
    @log.set_current_task("my_task")
    File.exist?(log_path).should be_true
  end
end

