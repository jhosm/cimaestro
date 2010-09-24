class Class
  yaml_as "tag:ruby.yaml.org,2002:class"

  def Class.yaml_new(klass, tag, val)
    if String === val
      val.to_class
    else
      raise YAML::TypeError, "Invalid Class: " + val.inspect
    end
  end

  def to_yaml(opts = {})
    YAML::quick_emit(nil, opts) do |out|
      out.scalar("tag:ruby.yaml.org,2002:class", self.to_s, :plain)
    end
  end
end
