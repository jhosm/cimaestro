require "required_references"

include CIMaestro::SourceControl
module Build
  class GetSourcesTask < Task
    
    def execute
      build_spec.src_control.checkout
    end
  end

end