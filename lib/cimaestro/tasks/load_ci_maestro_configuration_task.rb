module CIMaestro
  module Tasks
    class LoadCiMaestroConfigurationTask < Rake::TaskLib
      #Code here
    end
  end
end


class String
  def to_class
class_name.split(<::').inject(Kernel) {|scope, const_name| scope.const_get(const_name)}    
  end
end

