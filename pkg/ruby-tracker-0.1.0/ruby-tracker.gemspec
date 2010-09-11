# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-tracker}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Victor Zagorski"]
  s.date = %q{2010-09-09}
  s.description = %q{Allowes you to create a simple torrent tracker for your file sharing.}
  s.email = %q{victor@zagorski.ru}
  s.extra_rdoc_files = ["lib/core_ext/array.rb", "lib/core_ext/hash.rb", "lib/core_ext/integer.rb", "lib/core_ext/io.rb", "lib/core_ext/object.rb", "lib/core_ext/string.rb", "lib/torrent/bencode.rb", "lib/torrent/ruby-tracker.rb", "lib/torrent/tracker.rb"]
  s.files = ["Manifest", "Rakefile", "init.rb", "lib/core_ext/array.rb", "lib/core_ext/hash.rb", "lib/core_ext/integer.rb", "lib/core_ext/io.rb", "lib/core_ext/object.rb", "lib/core_ext/string.rb", "lib/torrent/bencode.rb", "lib/torrent/ruby-tracker.rb", "lib/torrent/tracker.rb", "rails/init.rb", "test/ruby-tracker-test.rb", "test/torrents/test.torrent", "ruby-tracker.gemspec"]
  s.homepage = %q{http://github.com/shaggyone/ruby-tracker}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Ruby-tracker"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-tracker}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Allowes you to create a simple torrent tracker for your file sharing.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
