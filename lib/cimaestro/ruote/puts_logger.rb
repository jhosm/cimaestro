require 'yaml'
require 'log4r'

class PutsLogger
  def initialize (context)

    @context = context
    @log = Log4r::Logger['simple']
    @context.worker.subscribe(['apply'], self) if @context.worker
  end

  def notify (msg)
    if msg['tree'][0] == 'participant' then
      @log.info '** ' + msg['workitem']['participant_name']
      if msg['workitem']['fields'].has_key?(msg['workitem']['participant_name']) then
        @log.info 'overrided options:'
        @log.info "\t" + YAML::dump(msg['workitem']['fields'][msg['workitem']['participant_name']]).gsub("\n", "\n\t")
      end
    end
  end
end