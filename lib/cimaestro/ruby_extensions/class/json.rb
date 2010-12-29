class Class

  def to_json(*a)
    {
        'json_class' => self.class.name,
        'data'       => [to_s]
    }.to_json(*a)
  end

  def self.json_create(o)
    o['data'][0].to_class
  end
end
