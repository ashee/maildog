#!/usr/bin/env ruby -w

require 'rubygems'
require 'sinatra'
require 'JSON'
require 'asciidoctor'
require 'mail'
require 'pp'
require 'redis'
require 'tilt'
require 'active_support/core_ext/numeric'

require 'sidekiq'
require 'sidekiq-status'

# $redis = Redis.new

class MailWorker
  include Sidekiq::Worker

  def perform(data)
	for event in data["events"]
		event_name = event["event"]
		template = "%s.ad" % File.join('templates', event_name.split('.'))
		send_mail Tilt.new(template, {:attributes => event }), event
	end
  end

  def send_mail(template, data)
	content = template.render
	puts content
	mail = Mail.new do
	  from     data["from"]
	  to       data["to"]
	  subject  data["subject"]
	  html_part do
	      content_type 'text/html; charset=UTF-8'
	      body content
	  end
	end
	# mail.delivery_method :sendmail
	# mail.deliver
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
end

Sinatra::Application.reset! if development?

module Sinatra::Templates
    def asciidoctor(template, options = {}, locals = {}, &block)
      render(:ad, template, options, locals, &block)
    end
end

get '/' do 
	content_type("text/plain")
	"====== REQUEST ========\n" + request.pretty_inspect()
	# request.pretty_inspect()
end	

post '/mail' do
	post_data = params[:data]
	data = JSON.parse(post_data)
	
	job_id = MailWorker.perform_async(data)

	# template_path = "./templates/" + event_name.gsub(".", "/") + ".ad" # clean-up hardcodes
	# lines = File.readlines(template_path)
	# doc = Asciidoctor::Document.new(lines, {:backend => 'html5', :header_footer => true,
	# 	:safe => Asciidoctor::SafeMode::SAFE, :attributes => {'linkcss!' => ''}
	# 	})
	# html_mail = doc.render()

end

if __FILE__ == $0 
	d = IO.read("data.json").sub /^data=/, ""
	ed = JSON.parse(d)
	MailWorker.new.perform(ed)
	exit 0
end

