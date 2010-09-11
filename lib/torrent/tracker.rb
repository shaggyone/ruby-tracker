Dir.glob(File.join(File.dirname(__FILE__), '..', 'core_ext', '*.rb')).each do |f|
  require f
end

require File.join(File.dirname(__FILE__), 'ruby-tracker')

module Torrent
  module PeerInfoModule
    attr_accessor :info_hash, :peer_id, :ip, :port, :status
    
    def self.get_or_create(params)
      peer = get_peer(params)
      peer = create_peer(params) if peer.nil?
      peer.save
      peer
    end

    def self.create_peer(params)
      raise NotImplementedError, 'Class method #{self.class.name}.create_peer to be overriden'
    end

    def self.get_peer(params)
      raise NotImplementedError, 'Class method #{self.class.name}.get_peer to be overriden'
    end

    def self.find_peers(params)
      raise NotImplementedError, 'Class method #{self.class.name}.find_peers to be overriden'
    end


    def update_info(params)
      port = params[:port]
      ip   = params[:ip]
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
      {
        'peer_id' => peer_id,
        'ip'      => ip,
        'port'    => port
      }.bencode
    end
  end

  class MemoryPeerInfo
    include PeerInfoModule
    attr_accessor :info_hash, :peer_id, :ip, :port, :status
    @@peers = {}

    def initialize(params={})
      [:info_hash, :peer_id, :ip, :port].each do |attr|
        self.send "#{attr}=", params[attr]
      end
    end

    def self.create_peer(params)
      MemoryPeerInfo.new(params)
    end

    def self.get_peer(params)
      peers_for_torrent = @@peers[params[:info_hash]] ||= []
      peers_for_torrent.find do |peer|
        peer.peer_info = params[:peer_info]
      end
    end

    def self.find_peers(params)
      @@peers[params[:info_hash]]
    end

  end


  module TorrentDirectory
    def self.allowed_torrent?(params)
        raise NotImplementedError, 'Method #{self.class.name}.allowed_torrent? supposed to be overriden'
    end

    def allowed_torrent?(params)
      self.class.allowed_torrent?(params)
    end
  end

  module TorrentTracker
    def torrent_directory

    end

    def torrent_directory=

    end

    def self.peer_info_class

    end

    def self.announce_process(params)
      _params = params.clone
      _params[:info_hash] = _params[:info_hash].unpack('H*').first

      return failure("Torrent not registered") unless torrent_directory.allowed_torrent?(_params)
      
      peer = peer_info_class.get_or_create(_params)

      case _params[:event]
      when 'stopped'
        peer.stop
      when 'completed'
        peer.complete
      when 'started'
        peer.start
      end
      raise "Error updating peer data" unless peer.save
      
      peer_info_class.find_peers(_params)    
    end

    def scrape(params)

    end

    def failure(text='Failure')
      {
        'failure reason' => text
      }
    end
  end


  class PeerInfo
    def initialize(params)
      @data = {
        :info_hash => params[:info_hash_hex],
        :port      => params[:port].to_i,
        :ip        => params[:ip],
        :peer_id   => params[:peer_id]
      }
    end

    def info_hash
      @data[:info_hash]
    end

    def port
      @data[:port].to_i
    end

    def ip
      @data[:ip]
    end

    def peer_status
      @data[:peer_status]
    end

    def peer_id
      @data[:peer_id]
    end
  end

  class Tracker
    def initialize
      @torrents = {}
      @peers = {}
    end

    def announce(params)
      return failure("Annouce request is incorrect") if params[:info_hash].nil? 
      params[:info_hash_hex] = params[:info_hash].unpack('H*').first
      params[:ip] ||= request.env['REMOTE_ADDR']
      if has_torrent?(params[:info_hash_hex])
        response_text list_peers(params)
      else
        failure "Torrent is not registered"
      end
    end

    def failure(failure_reason="Failed")
      {
        "failure reason" => failure_reason
      }.bencode
    end

    def has_torrent?(info_hash)
      @torrents.key?(info_hash)
    end

    def list_peers(params)
      add_peer(params)
      @peers[params[:info_hash_hex]]
      #info_hash = params[:info_hash].unpack('H*').first
    end

    def add_peer(params)
      key = key_for(params)
      @peers[params[:info_hash_hex]] ||= {}
      @peers[params[:info_hash_hex]][key] = PeerInfo.new(params)
    end

    def key_for(params)
      "#{params[:ip]}#{params[:inho_hash_hex]}"
    end

    def add_torrent(data)
      bt = BencodedRecord.load(data)
      #bt = Torrent::BencodedRecord.load(data)
      @torrents[bt.info.hexdigest] = bt
    end

    def response_text(peers)
      p = peers.map do |key, x|
        {
          'peer_id' => x.peer_id.to_s,
          'ip'      => x.ip.to_s,
          'port'    => x.port.to_i
        }
      end
      pp p
      p.bencode
    end
  end

  class SinatraTracker < Tracker
  end
end
