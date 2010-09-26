lib_dir = File.dirname(__FILE__)

Dir.glob(File.join(lib_dir, 'torrent', '*.rb')).compact.each do |f|
  require f
end
