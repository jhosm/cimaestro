require 'spec_helper'
require 'rubygems'
require 'ruote'
require 'cimaestro/ruote/process_launcher'
require 'cimaestro/ruote/ruote_spec_helper'

BLACKBOARD = {}
class WriteToBlackboardTask
  def initialize(build_spec, workitem, logger) end
  def setup ; end
  def execute
    BLACKBOARD["ping"] = true
  end
end

module CIMaestro
  module Ruote
    describe ProcessLauncher do
      include RuoteSpecHelper

      before :each do
        BLACKBOARD["ping"] = false
      end

      def write_to_blackboard_process
        return ::Ruote.process_definition do
           write_to_blackboard
        end
      end

      it "should launch a process" do
        subject().launch(write_to_blackboard_process, get_required_workitem_for_process_startup())
        BLACKBOARD["ping"].should be_true
      end
    end
  end
end