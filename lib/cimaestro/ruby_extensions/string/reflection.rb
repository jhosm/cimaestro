module CIMaestro
  module RubyExtensions
    module String
      module Reflection
        def to_class()
          result = self.split('::').inject(Kernel) do |scope, const_name|
            scope.const_get(const_name)
          end
          raise NameError.new("The string translates to a Constant which is not a Class.", self) unless result.is_a? Class
          result
        end
      end
    end
  end
end
class String
  include CIMaestro::RubyExtensions::String::Reflection
end
