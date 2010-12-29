require 'rubygems'
require 'rufus-json'

class OpenStruct

  def to_json(*a)
    {
      'json_class'   => self.class.name,
      'data'         => [ Rufus::Json.encode(table)]
    }.to_json(*a)
  end

  def self.json_create(o)

    OpenStruct.new(Rufus::Json.decode(o['data'][0]))
  end
end