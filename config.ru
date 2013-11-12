require 'rubygems'
require 'rack/reloader'

$LOAD_PATH.unshift File.dirname(__FILE__) 
require 'init'

set :run, false
enable :run, :reload
set :environment, :development
set :views, 'templates'

use Rack::Reloader, 0 if development?

require 'sidekiq/web'
run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)

# run Sinatra::Application
