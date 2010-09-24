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
