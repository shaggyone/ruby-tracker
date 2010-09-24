require 'digest/sha1'

module Torrent
  
  class BencodedRecord
    def self.has_subrecords(*added_subrecords)
      @@subrecords ||= []
      @@subrecords += added_subrecords.map  {|x| x.to_s}
    end

    def self.load(str)
      scanner = StringScanner.new(str)
      obj = parse(scanner)
      raise BEncode::DecodeError unless scanner.eos?
      return obj
    end

    def initialize(*args)
      #@bencoded_fields = {}
      #@bencoded_hashs  = {}
      #@dirty_flags = {}
      @data = {}
      @bencoded_data = ""
      @dirty = false
      if args.size>=1 then     
        data = args.first
        @@subrecords ||= []
        @subrecord_objects ||= {}
        data.each do |key, value|
          set_value key, value
        end
        @dirty = true
      end
    end

    def bencode
      if dirty?
        pairs = fields.sort.map do |key| 
          [key.to_s.bencode, get_value(key).bencode]
        end
        "d#{pairs.join}e"
      else
        @bencoded_data
      end
    end

    def hexdigest
      if dirty?
        Digest::SHA1.hexdigest(bencode)
      else
        Digest::SHA1.hexdigest(bencode)
      end
    end

    def fields
      @data.keys
    end

    def set_value(field_name, value)
#     @dirty_flags[field_name] = true
      @dirty = true
      if value.kind_of?(Hash)
        @data[field_name] = BencodedRecord.new(value)
      else
        @data[field_name] = value 
      end
    end

    def get_value(field_name)
      @data[field_name]
    end

#    def get_field_hash(field_name)
#      if field_dirty?(field_name)
#        get_bencoded_data(field_name)
#      else
#        ::Digest::SHA1.hexdigest(@bencoded_hashs[field_name])
#      end
#    end

#    def get_bencoded_data(field_name)
#      if @data[field_name].nil? then
#        return nil
#      end
#      if field_dirty?(field_name) then
#        field_name.bencode + @data[field_name].bencode
#      else
#        @bencoded_fields[field_name]
#      end
#    end

    def field_dirty?(field_name)
      @dirty_flags[field_name]
    end

    def save
      @dirty = false      
      @data.each do |key,obj|
        if obj.kind_of?(BencodedRecord)
          obj.save
        end
      end
    end
# private
    def set_bencoded_data(bencoded_data)
      @dirty = false
      @bencoded_data = bencoded_data
    end

    def set_field_bencoded_data(field_name, bencoded_value, value)
      #@bencoded_fields[field_name] = bencoded_value
      #@bencoded_hashs[field_name]  = ::Digest::SHA1.hexdigest(bencoded_value)
      #@dirty_flags[field_name] = false
      @data[field_name] = value
    end

    def self.parse(scanner)
      val = case scanner.peek(1)[0]
            when ?i # integer
              scanner.pos += 1
              num = scanner.scan_until(/e/) or raise BEncode::DecodeError
              num.chop.to_i 
            when ?l # array
              scanner.pos += 1
              arr = []
              arr.push(parse(scanner)) until scanner.scan(/e/)
              arr
            when ?d
              start_pos = scanner.pos
              scanner.pos += 1
#             field_start_pos = scanner.pos
              rec = self.new
              until scanner.scan(/e/)
                field_name = parse(scanner)
                unless field_name.is_a? String or field_name.is_a? Fixnum
                  raise BEncode::DecodeError, "key must be a string or number"
                end
                field_name = field_name.to_s
                field_value = parse(scanner)
#                field_end_pos = scanner.pos
#               bencoded_value = scanner.string[field_start_pos, field_end_pos-field_start_pos]
#               rec.set_field_bencoded_data field_name, bencoded_value, field_value
                rec.set_value field_name, field_value
#               field_start_pos = field_end_pos
              end
              end_pos = scanner.pos
              rec.set_bencoded_data scanner.string[start_pos, end_pos-start_pos]
#             rec.save
              rec
            when ?0 .. ?9
              num = scanner.scan_until(/:/) or
                raise BEncode::DecodeError, "invalid string length (no colon)"
              begin
                length = num.chop.to_i
                str = scanner.peek(length)
                scanner.pos += num.chop.to_i
              rescue 
                raise BEncode::DecodeError, "invalid string length"
              end
              str
            end
      raise BEncode::DecodeError if val.nil?
      val          
    end

    def method_missing(method_name, *args, &block)
      mn = method_name.to_s
      if mn.end_with?("=") then
        field_name = mn[0, mn.length-1]
        set_value field_name, args.first
      else
        field_name = mn
        get_value(mn)
      end
    end

    def dirty?
      return true if @dirty
      @data.each do |key,obj|
        if obj.kind_of?(BencodedRecord)
          return true if obj.dirty?
        end
      end
      false
    end
  end

  class TorrentData < BencodedRecord
    has_subrecords :info
  end

  class Torrent
    def self.from_file(filename)
      Torrent.new(File.read(filename))
    end

    def initialize(data)
      @torrent_data = BencodedRecord.load(data)
    end

    def method_missing(*args)
      self.call2(*args)
    end
  end

  module TorrentCatalog
    def get_torrent(info_hash, options={})

    end
  end
end
