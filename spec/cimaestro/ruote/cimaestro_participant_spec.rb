require 'spec_helper'
require 'rubygems'
require 'ruote'
require 'cimaestro/ruote/ci_maestro_participant'
require 'cimaestro/ruote/ruote_spec_helper'

class ASampleTask

  class << self
    attr_accessor :build_spec, :logger, :instantiated, :num_of_setups, :num_of_executions, :received_workitem

    def clear
      instantiated = false
      num_of_setups = 0
      num_of_executions = 0
      workitem = {}
      build_spec = nil
      logger = nil
    end
  end

  def initialize(build_spec, workitem, logger)
    ASampleTask.build_spec = build_spec
    ASampleTask.instantiated = true
    ASampleTask.num_of_setups = 0
    ASampleTask.num_of_executions = 0
    ASampleTask.received_workitem = workitem
    ASampleTask.logger = logger
  end

  def setup
    ASampleTask.num_of_setups += 1
  end

  def execute
    ASampleTask.num_of_executions += 1
  end
end


module CIMaestro
  module Ruote
    describe CIMaestroParticipant do
      include RuoteSpecHelper

      def launch_process(workitem={})
        pdef = ::Ruote.process_definition do
           throw_error :if => '${f:should_throw_error}'
           a_sample
        end
        workitem.merge!(get_required_workitem_for_process_startup())
        wfid = @engine.launch(pdef, workitem)
        @engine.wait_for(wfid)
        return wfid
      end

      before :each do
        ASampleTask.clear
        @engine = ::Ruote::Engine.new(::Ruote::Worker.new(::Ruote::HashStorage.new()))

        @engine.register_participant /.*/, CIMaestroParticipant
        #@engine.noisy = true
      end

      it "should infer the task's class name from the process definition's step name" do
        launch_process
        ASampleTask.instantiated.should be_true
      end

      it "should throw a helpful message if a participant name is not convertible to a cimaestro task" do
        wfid = launch_process({'should_throw_error' => true})
        errors = @engine.process(wfid).errors
        errors.size.should == 1
        errors.first.message.should == "#<CIMaestro::Exceptions::InvalidParticipantNameException: Could not create a task based on the participant's name: throw_error. Please make sure there's a defined class called ThrowErrorTask.>"
      end

      it "should instantiate BuildSpec and give it to the task" do
        launch_process({'build_config' => BuildConfig.new("system", "mainline", 'c:').to_ostruct})
        ASampleTask.build_spec.should be_kind_of(Configuration::BuildSpec)
      end

      it "should configure a logger and inject it to the task" do
        launch_process({'logger_class' => ConsoleLogger})
        ASampleTask.logger.should be_kind_of(ConsoleLogger)
      end

      it "should pass only the workitem data pertaining to the executing task" do
        launch_process({'my_item' => 0})
        ASampleTask.received_workitem.should == nil

        launch_process({'a_sample' => {'setting' => 0}, 'my_item' => 0})
        ASampleTask.received_workitem.should == {'setting' => 0}
      end

      it "should setup the task" do
        launch_process
        ASampleTask.num_of_setups.should == 1
      end

      it "should execute the task" do
        launch_process
        ASampleTask.num_of_executions.should == 1
      end
    end
  end
end