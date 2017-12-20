require 'json'
require 'rgeo/shapefile'

def read_streets
  RGeo::Shapefile::Reader.open(File.dirname(__FILE__) + '/lib/shp/roads.shp') do |file|
    streets = []
    file.each do |record|
      if record.attributes['name'] != ''
    #     puts "Record number #{record.index}:"
    #     puts "  Geometry: #{record.geometry.as_text}"
    #     puts "  Attributes: #{record.attributes.inspect}"

        street = {}
        street[:osm_id] = record.attributes['osm_id']
        street[:name] = record.attributes['name'].force_encoding("utf-8")
        street[:ref] = record.attributes['ref']
        street[:type] = record.attributes['type']
        street[:oneway] = record.attributes['oneway']
        street[:bridge] = record.attributes['bridge']
        street[:maxspeed] = record.attributes['maxspeed']
        street[:geometry] = record.geometry.to_json
        streets << street
      end
    end
    streets
    # file.rewind
    # record = file.next
    # puts "First record geometry was: #{record.geometry.as_text}"
  end
end


File.open("streets.json","w") do |f|
  f.write(read_streets.to_json)
end