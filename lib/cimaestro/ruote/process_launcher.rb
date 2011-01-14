module CIMaestro::Ruote
  class ProcessLauncher
    def launch(pdef, workitem)
      @engine = ::Ruote::Engine.new(::Ruote::Worker.new(::Ruote::HashStorage.new()))
      @engine.register_participant /.*/, CIMaestroParticipant
      @engine.noisy = true
      wfid = @engine.launch(pdef, workitem)
      @engine.wait_for(wfid)
    end
  end
end