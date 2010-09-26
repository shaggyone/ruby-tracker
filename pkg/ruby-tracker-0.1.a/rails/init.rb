lib_dir = File.join(File.dirname(__FILE__), '..', 'lib')

#(Dir.glob(File.join(lib_dir, 'core_ext', '*.rb'))
Dir.glob(File.join(lib_dir, 'torrent', '*.rb')).compact.each do |f|
  require f
end

