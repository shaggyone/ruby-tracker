require 'rubygems'
require 'test/unit'
require 'pp'
gem 'activesupport'
#require 'torrent/bencode'
#gem 'test-unit'

lib_dir = File.join(File.dirname(__FILE__), *%w[.. lib])
require File.join(lib_dir, 'torrent', 'ruby-tracker')
require File.join(lib_dir, 'torrent', 'bencode')
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
    r = Torrent::BencodedRecord.new({'a' => 10, 'b' => 20})
    assert_equal 10, r.get_value('a')
    assert_equal 20, r.b

    r2 = Torrent::BencodedRecord.load("d3:bar4:spam3:fooi42ee")
    assert_equal "spam", r2.get_value('bar')
  end

  def test_torrent_info
    r = Torrent::TorrentData.new({'a' => 10, 'b' => 20, 'info'=>{'a'=>'hello'}})
    assert_equal 10, r.a
    assert_equal 'hello', r.info.a
  end

  def test_torrent_info_2
    filename = Dir.glob(File.join(File.dirname(__FILE__), "torrents", "*.torrent")).first
    torrent_data = File.read(filename)

    r2 = Torrent::TorrentData.load(torrent_data)
#   puts "info_hash: #{r2.info.hexdigest}"
    assert_equal "eca505dc632dd3ae982843af72650373306f61cf", r2.info.hexdigest
    
    assert ! r2.dirty?, "r2 SHOULD NOT be dirty after loading"
    assert ! r2.info.dirty?, "Info field SHOULD NOT be dirty after loading"
    
    r2.info.private = 0
    assert r2.dirty?, "r2 SHOULD NOT be dirty after loading"
    assert r2.info.dirty?, "Info field SHOULD be dirty after modifing any of any field" 
  end
end
