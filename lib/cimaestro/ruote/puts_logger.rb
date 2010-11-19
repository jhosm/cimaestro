require 'yaml'
class PutsLogger
  def initialize (context)

    @context = context

    @context.worker.subscribe(['apply'], self) if @context.worker
  end

  def notify (msg)
    if msg['tree'][0] == 'participant' then
      puts '** ' + msg['workitem']['participant_name']
      if msg['workitem']['fields'].has_key?(msg['workitem']['participant_name']) then
        puts 'overrided options:'
        puts "\t" + YAML::dump(msg['workitem']['fields'][msg['workitem']['participant_name']]).gsub("\n", "\n\t")
      end
    end
  end
end