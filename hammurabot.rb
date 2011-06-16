# coding: utf-8

room = camp.choose_room!

room.listen do |message|
  OpenStruct.new(message).instance_eval do
    next if body.nil?
    mode, reply = :paste, nil
    
    case body.to_s
      
    when /\bhammurabi\:(.*)?/i
      reply = Hammurabi.find($1)
      mode, reply = :speak, 'we have no law for that' if reply.nil?
      
    when /h?amm?urr?ab[iy]/i
      reply = Hammurabi.law!
      
    else replied = false
    end
    
    if reply
      room.send(mode, reply)
      Notify.notify body, reply
    end
    
    $stdout.print reply ? 'H' : '.'
    $stdout.flush
  end
end









BEGIN {
  require 'rubygems'
  require 'bundler/setup'
  
  require 'tinder'
  require 'uri'
  require 'yajl/http_stream'
  require 'notify'
  require 'ostruct'
  require 'hammurabi'
  require 'yaml'
  
  class Tinder::Campfire
    def choose_room!
      rooms.each_with_index do |room, index|
        position = index+1
        $stdout.puts "#{position}. ".ljust(5) << room.name.ljust(20) << room.id.to_s
      end

      print 'chose room: '
      $stdout.flush
      room_index = gets.chomp.to_i-1
      rooms[room_index].tap { |room|
        room.join
        puts "Entered room #{room.name}."
      }
    end
  end
  
  config = YAML.load_file File.expand_path('../config.yml', __FILE__)
  user     = config['user']
  password = config['password']
  token    = config['token']
  company  = config['company']
  camp = Tinder::Campfire.new company, :token => token
  
  
}





