require 'rubygems'
require 'test/unit'
require 'pp'
gem 'activesupport'
gem 'bencode'
#gem 'test-unit'

lib_dir = File.join(File.dirname(__FILE__), *%w[.. lib])
require File.join(lib_dir, 'ruby-tracker')
require File.join(lib_dir, 'bencode')
Dir.glob(File.join(lib_dir, 'core_ext', '*.rb')).each do |f|
  require f
end

class RubyTrackerTest < Test::Unit::TestCase
  def test_bencode
    assert_equal "i10e", 10.bencode
    assert_equal "4:spam", "spam".bencode
    assert_equal "l4:spami42ee", ["spam", 42].bencode
    assert_equal "d3:bar4:spam3:fooi42ee", {'bar'=>'spam', 'foo'=>42}.bencode
  end

  def test_bdecode
    record = "d3:bar4:spam3:fooi42ee"
    assert_equal "spam", record.bdecode['bar']
    assert_equal 42, record.bdecode['foo']
  end

  def test_bencoded_record
    r = RubyTracker::BencodedRecord.new({'a' => 10, 'b' => 20})
    assert_equal 10, r.get_value('a')
    assert_equal 20, r.b

    r2 = RubyTracker::BencodedRecord.load("d3:bar4:spam3:fooi42ee")
    pp r2
    assert_equal "spam", r2.get_value('bar')
  end

  def test_torrent_info
    filename = Dir.glob(File.join(File.dirname(__FILE__), "torrents", "*.torrent")).first
    torrent_data = File.read(filename)
    r = RubyTracker::TorrentData.new({'a' => 10, 'b' => 20, 'info'=>{'a'=>'hello'}})
    assert_equal 10, r.a
    assert_equal 'hello', r.info.a
#   assert !r.dirty?
#   r.info.c = 30
#   assert r.info.dirty?
    #pp r.subrecords_objects
#   assert r.dirty?
    r2 = RubyTracker::TorrentData.load(torrent_data)
    pp r2
    puts r2.get_bencoded_data("info")
    puts "info_hash: #{r2.info.hexdigest}"
    
    puts r2.info.bencode
    pp r2.get_field_hash("info")
    assert r2.info.dirty?, "Info hash SHOULD NOT be dirty after loading"
    r2.info.private = 0
    assert r2.info.dirty?, "Info hash SHOULD be dirty after modifing any of any field" 
  end
end
