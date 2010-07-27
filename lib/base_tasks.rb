module Build

  class Task
    attr_reader :build_spec, :rake_name, :logger

    def initialize(rake_name = "", build_spec = nil, logger = ConsoleLogger.new)
      @build_spec = build_spec
      @rake_name = rake_name
      @logger = logger
    end

    def setup
    end

    def execute
    end
  end

  class NullTask < Task
    def setup
    end

    def execute
      @logger.log_msg "#{@rake_name} is a NullTask, probably because this is an incremental build."
    end
  end

  class ExecutionTimeTask < Task
    attr_reader :duration, :task

    def initialize(task, build_spec, logger= NullLogger.new)
      super(task.rake_name, build_spec, logger)
      @task = task
    end

    def setup
      @start = Time.now
      @task.setup
    end

    def execute
      begin
        @task.execute
      ensure
        @duration = Time.now - @start
        @logger.log_duration(@duration)
      end
    end
  end

end
