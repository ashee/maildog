require 'rubygems'
require 'bundler'

Bundler.require
$LOAD_PATH.unshift File.dirname(__FILE__) 

require 'init'

set :run, false
set :environment, :development

run Sinatra::Application