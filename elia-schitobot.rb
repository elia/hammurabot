# coding: utf-8

camp = Tinder::Campfire.new config.company, :token => config.token
room = config.room ? camp.find_room_by_name(config.room) : camp.choose_room!
name_regex = /\b#{config.name}\b/i

room.listen do |message|
  OpenStruct.new(message).instance_eval do
    next if body.nil? or (user and user[:name] =~ name_regex)
    
    if body.to_s =~ name_regex
      reply = "#{user[:name]}: #{PHRASES[rand(PHRASES.size-1)]}"
      
      puts "Got message: #{body}"
      puts "Replied with: #{reply}"
      
      Thread.new {
        room.speak(reply)
      }
      
      Thread.new {
        Pony.mail(
          to:      "#{config.mail_user}@mikamai.com", 
          from:    "#{config.mail_user}+bot@mikamai.com", 
          subject: "[#{config.mail_user.upcase}BOT] Mentioned on CampFire by #{user[:name]}", 
          body:    "Got message: \n#{body}"+
                   "\n\n\n"+
                   "Replied with: \n#{reply}"
        )
      }
      
      
      $stdout.print reply ? 'E' : '.'
      $stdout.flush
      
    end
    
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
  require 'yaml'
  require 'pony'
  
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
  
  Pony.options = {
    via: :smtp, 
    via_options: {
      address:        'smtp.gmail.com',
      port:           587,
      user_name:      config.mail_user,
      password:       config.mail_password,
      authentication: :plain,
      domain:         'mikamai.com'
    }
  }

  PHRASES = %Q{
    un'attimo
    un momento che arrivo
    lol
    asp
    sono al telefono
    un secondo che c'è liz che rompe
  }.split("\n").map(&:strip)

  Thread.abort_on_exception

}






