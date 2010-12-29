require "rexml/document"

class NullLogger
  def set_current_task(task_name)
  end

  def log_msg(text)
  end

  def log_error(text)
  end

  def log_duration(duration_in_seconds)
  end
end

class ConsoleLogger
  def set_current_task(task_name)
    @task_name = task_name
    puts
    puts "[#{task_name}]"
  end

  def log_msg(text)
    puts text
  end

  def log_error(text)
    puts "ERROR ->" + text
  end

  def log_duration(duration_in_seconds)
    puts "#{@task_name}'s duration: [#{duration_in_seconds}]"
  end
end

class NAntCompatibleXmlLogger
  include REXML
  def initialize(system_name, log_path)
    @log_path = log_path
    FileUtils.mkpath(File.dirname(@log_path)) unless File.exist?(File.dirname(@log_path))
    @log = Document.new "<buildresults project=\"#{system_name}\"><duration>0</duration></buildresults>"
    @root = @log.root
    @build_duration = @log.root[0]
    @current_task = nil
    save
  end

  def set_current_task(task_name)
    if @root.elements["target[@name='#{task_name}']/task[@name='#{task_name}']"] != nil then
      @current_task = @root.elements["target[@name='#{task_name}']/task[@name='#{task_name}']"]
    else
      target = Element.new("target")
      target.attributes["name"] = task_name
      @current_task = target.add_element "task", "name" => task_name
      @root.insert_before(@build_duration, target)
    end
    save
  end

  def log_msg(text)
    raise "You must set a current task first." if @current_task == nil
    add_message_element @current_task, "Info", text
    save
  end

  def log_error(text)
    failure = Element.new("failure")
    build_error = failure.add_element("builderror")
    add_message_element build_error, "Error", text
    @root.insert_before(@build_duration, failure)
    save
  end

  protected

  def add_message_element(parent, level, text)
    text.split("\n").each do |line|
      parent.add_element("message", {"level" => level}).text = CData.new(line)
    end
  end

  public

  def log_duration(duration_in_seconds)
    raise "You must set a current task first." if @current_task == nil
    raise ArgumentError, "duration_in_seconds must be a float." unless Float === duration_in_seconds
    millisecs = duration_in_seconds * 1000
    @current_task.add_element("duration").text = millisecs
    @current_task.parent.add_element("duration").text = millisecs
    @build_duration.text = Float(@build_duration.text) + millisecs
    save
  end

  def current_log
    @log
  end

  def save
    File.open(@log_path, "w") do |file|
      file.puts current_log
    end
  end
end

