
require 'rubygems'
require 'json'
require 'rufus-json' # gem install rufus-json


class Class
  def to_json(*a)
    {
      'json_class'   => self.class.name,
      'data'         => [ to_s ]
    }.to_json(*a)
  end

  def self.json_create(o)
    o['data'][0].to_class
  end
end


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

b = OpenStruct.new({ 'a' => OpenStruct, 'b' => true })

p Rufus::Json.encode(b)
p Rufus::Json.decode(Rufus::Json.encode(b)).a




