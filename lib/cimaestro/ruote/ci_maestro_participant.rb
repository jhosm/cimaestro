require 'ruote'
require 'active_support'
require 'cimaestro/ruote/invalid_participant_name_exception'

module CIMaestro
  module Ruote
    class CIMaestroParticipant
       include ::Ruote::LocalParticipant

        def initialize (opts=nil)
        end

        def consume (workitem)
          build_config = BuildConfig.new
          build_config.merge!(workitem.fields['build_config'])

          part_name = workitem.participant_name
          begin
            klass_name = "#{part_name}_task".camelize
            klass = klass_name.to_class
          rescue NameError => ex
            raise Exceptions::InvalidParticipantNameException, "Could not create a task based on the participant's name: #{part_name}. Please make sure there's a defined class called #{klass_name}."
          end

          task = klass.new(Configuration::BuildSpec.new("", "", "", "", build_config), workitem.fields[part_name], ConsoleLogger.new)
          task.setup
          task.execute
          reply_to_engine(workitem)
        end

        def cancel (fei, flavour)
          # nothing to do
        end
    end
  end
end