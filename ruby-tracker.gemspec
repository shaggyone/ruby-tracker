Gem::Specification.new do |s|
  s.name = "ruby-tracker"
  s.version = "0.1"
  s.authors = ["Victor Zagorski"]
  s.email = "vzagorski@inbox.ru"
  s.homepage = 'http://github.com/shaggyone/ruby-tracker'
  s.summary = 'This gem allows you add torrent tracker functionality to your web app. 'll work on Ruby On Rails and Sinatra"
  s.description = "Same as summary."

  s.files = Dir["lib/**/*", "[A-Z]*", "init.rb", "rails/init.rb", "install.rb", "ruby-tracker.gemspec"]
  s.test_files = Dir["test/**/*"]
# s.require_path = "lib"

  s.extra_rdoc_files = Dir["*.rdoc"]

  s.required_rubygems_version = ">= 1.3.4"
  s.autorequire = "ruby-tracker"
  s.has_rdoc = false
  s.require_paths = ["lib"]
  s.add_dependency "bencode"
end