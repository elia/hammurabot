# coding: utf-8

camp = Tinder::Campfire.new config.company, :token => config.token
room = config.room ? camp.find_room_by_name(config.room) : camp.choose_room!

room.listen do |message|
  OpenStruct.new(message).instance_eval do
    next if body.nil?
    mode, reply = :paste, nil
    
    case body.to_s
      
    when /\bhammurabi\s+(.*)?/i
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
  class Tinder::Room
    alias weak_listen listen
    
    def listen &block
      weak_listen(&block)
    rescue => e
      puts "#{e.class}: #{e}"
      retry
    end
  end
  
  
  
  def config
    return @config if @config
    
    yaml_config_file = File.expand_path('../config.yml', __FILE__)
    if File.exist?(yaml_config_file)
      config_hash = YAML.load_file(yaml_config_file)
    else
      config_hash = {}
      ENV.each_pair do |k,v| 
        config_hash[$1.downcase] = v if k =~ /^HAMMURABOT_(.*)$/
      end
    end
    @config = OpenStruct.new config_hash
  end
  
}





