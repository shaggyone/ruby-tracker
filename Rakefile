require 'rubygems'  
require 'rake'  
require 'echoe'  
  
Echoe.new('ruby-tracker', '0.1.1') do |p|  
    p.description     = "Allowes you to create a simple torrent tracker for your file sharing."  
    p.url             = "http://github.com/shaggyone/ruby-tracker"  
    p.author          = "Victor Zagorski aka shaggyone"  
    p.email           = "victor@zagorski.ru"  
    p.ignore_pattern  = ["tmp/*", "script/*"]  
    p.development_dependencies = []  
end  
  
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
