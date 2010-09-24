Dir.glob(File.join(File.dirname(__FILE__), '..', 'core_ext', '*.rb')).each do |f|
  require f
end

require File.join(File.dirname(__FILE__), 'ruby-tracker')
require 'ipaddr'

module Torrent

  module PeerInfoModule

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      attr_accessor :info_hash, :peer_id, :ip, :port, :status, :left, :downloaded, :uploaded

      def act_as_peer_info
        send :include, InstanceMethods
      end
    
      def get_or_create(params)
        peer = get_peer(params)
        peer = create_peer(params) if peer.nil?
        peer.save
        peer
      end

      def create_peer(params)
        raise NotImplementedError, 'Class method #{self.class.name}.create_peer to be overriden'
      end

      def get_peer(params)
        raise NotImplementedError, 'Class method #{self.class.name}.get_peer to be overriden'
      end

      def find_peers(params)
        raise NotImplementedError, 'Class method #{self.class.name}.find_peers to be overriden'
      end
    end

    module InstanceMethods
      def update_info(params)
        [:port, :ip, :left, :downloaded, :uploaded].each do |x|
          self.send "#{x}=", params[x]
        end
#       port = params[:port]
#       ip   = params[:ip]
      end

      def start(params)
        update_info(params)
        status = "started"
      end

      def stop(params)
        update_info(params)
        status = "stopped"
      end

      def complete(params)
        update_info(params)
        status = "completed"
      end 

      def save
        true
      end

      def started(params)
        raise NotImplementedError, 'Instance method #{self.class.name}.started supposed to be overriden'
      end

      def stoped(params)
        raise NotImplementedError, 'Instance method #{self.class.name}.stoped supposed to be overriden'
      end

      def completed(params)
        raise NotImplementedError, 'Instance method #{self.class.name}.completed supposed to be overriden'
      end

      def bencode
        to_hash.bencode
      end

      def to_hash
        a = {
          'peer id' => peer_id,
          'ip'      => ip,
          'port'    => port.to_i
        }
      end

      def pack
        IPAddr.new(ip).hton + [port.to_i].pack('n')
      end
    end
  end

  class MemoryPeerInfo
    include PeerInfoModule
    act_as_peer_info

    attr_accessor :info_hash, :peer_id, :ip, :port, :status, :left, :downloaded, :uploaded
    @@peers = {}

    def initialize(params={})
      [:info_hash, :peer_id, :ip, :port].each do |attr|
        self.send "#{attr}=", params[attr]
      end
    end

    def self.create_peer(params)
      a = @@peers[params[:info_hash]] ||= []
      a.push(b=self.new(params))
      b
    end

    def self.get_peer(params)
      peers_for_torrent = @@peers[params[:info_hash]] ||= []
      peers_for_torrent.find do |peer|
        peer.peer_id == params[:peer_id]
      end
    end

    def self.find_peers(params)
      pp params
      @@peers[params[:info_hash]].find_all do |peer|
        peer.peer_id != params[:peer_id]
        true
      end
    end

  end


  module Directory
    def self.allowed_torrent?(params)
        raise NotImplementedError, 'Method #{self.class.name}.allowed_torrent? supposed to be overriden'
    end

    def allowed_torrent?(params)
      self.class.allowed_torrent?(params)
    end
  end

  class Tracker
    attr_accessor :torrent_directory, :peer_info_class

    def announce(params)
      _params = params.clone
      _params[:info_hash] = _params[:info_hash].unpack('H*').first

      return failure("Torrent not registered") unless torrent_directory.allowed_torrent?(_params)
      
      peer = peer_info_class.get_or_create(_params)

      case _params[:event]
      when 'stopped'
        peer.stop _params
      when 'completed'
        peer.complete _params
      when 'started'
        peer.start _params
      end
      raise "Error updating peer data" unless peer.save
     
      #peers = peer_info_class.find_peers(_params).map do |x|
      #  x.ip
      #end

      if _params[:compact].to_s=="0" then
        {'peers' => peer_info_class.find_peers(_params).map do |x| x.to_hash end}
      else
        {'peers' => peer_info_class.find_peers(_params).map do |x| x.pack end.join("").to_s}
      end 
    end

    def scrape(info_hashs)
#     failure 'Scrape requests are not supported yet'
      files = {}      
      info_hashs.each do |x|
        info_hash = x.unpack('H*').first
        torrent = torrent_directory[info_hash]
        files[x] = {
          'complete'   => 1,
          'downloaded' => 3,
          'incomplete' => 3,
          'name' => torrent['info']['name']
        }        
      end
      { 'files' => files }
    end

    def failure(text='Failure')
      {
        'failure reason' => text
      }
    end
  end
end
