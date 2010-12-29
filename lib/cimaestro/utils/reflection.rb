module CIMaestro::Utils
  module Reflection
    def instance_variables_as_hash
      instance_variables.inject({}) do |hash, ivar|
        attr_reader_name =ivar.gsub('@', '').to_sym
        hash.merge(attr_reader_name => self.send(attr_reader_name))
      end
    end
  end
end
