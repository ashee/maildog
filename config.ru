require 'rubygems'

$LOAD_PATH.unshift File.dirname(__FILE__) 
require 'init'

set :run, false
set :environment, :development
set :views, 'templates'

require 'sidekiq/web'
run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)

# run Sinatra::Application
