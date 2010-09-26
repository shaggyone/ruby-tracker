# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-tracker}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Victor Zagorski aka shaggyone"]
  s.date = %q{2010-09-26}
  s.description = %q{Allowes you to create a simple torrent tracker for your file sharing.}
  s.email = %q{victor@zagorski.ru}
  s.extra_rdoc_files = ["README", "lib/ruby-tracker.rb", "lib/torrent/tracker.rb"]
  s.files = ["Gemfile", "Gemfile.lock", "Manifest", "README", "Rakefile", "init.rb", "lib/ruby-tracker.rb", "lib/torrent/tracker.rb", "rails/init.rb", "ruby-tracker.gemspec", "test/ruby-tracker-test.rb", "test/torrents/test.torrent"]
  s.homepage = %q{http://github.com/shaggyone/ruby-tracker}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Ruby-tracker", "--main", "README"]
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
