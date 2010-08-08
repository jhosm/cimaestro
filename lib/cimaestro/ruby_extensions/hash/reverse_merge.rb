module CIMaestro
  module RubyExtensions
    module Hash
      module ReverseMerge
        def reverse_merge(other_hash)
          other_hash.merge(self)
        end

        def reverse_merge!(other_hash)
          replace(reverse_merge(other_hash))
        end
      end
    end
  end
end
class Hash
  include CIMaestro::RubyExtensions::Hash::ReverseMerge
end