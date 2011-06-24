require 'yaml'

desc 'upload config to heroku from a local config.yml (set APP=myapp to specify the heroku app name)'
task :upload_config do
  yaml_config_file = File.expand_path('../config.yml', __FILE__)
  config_hash = YAML.load_file(yaml_config_file)
  
  system 'heroku', 'config:add', *config_hash.to_a.map{|(k,v)| "HAMMURABOT_#{k.upcase}=#{v}"}
end