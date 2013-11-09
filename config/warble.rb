# config/warble.rb
Warbler::Config.new do |config|
  config.dirs = %w(config templates)
  config.includes = FileList["init.rb"]
  # config.gems -= ["warbler"]
  # config.gem_dependencies = true
end