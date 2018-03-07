# encoding: UTF-8

require 'json'
require_relative './lib/level'

file = File.read('c:\Users\Fr1end\Downloads\57016\57016_6_1.json')
level_json = JSON.parse(file)

level = Level.new(level_json)

puts level.full_info(level_json)

file = File.read('c:\Users\Fr1end\Downloads\57016\57016_6_2.json')
level_json = JSON.parse(file)

puts level.updated_info(level_json)
puts level.all_sectors(level_json)
puts level.needed_sectors(level_json)