#!/usr/bin/env ruby -w

require 'rubygems'
require 'sinatra'
require 'JSON'
require 'asciidoctor'
require 'mail'

get '/' do 
	"hello,world. Welcome to the world of Sinatra"
end

post '/mail' do
	post_data = params[:data]
	data = JSON.parse(post_data)

	# find template based on event name and render template
	event_name = data["event"]
	template_path = "./templates/" + event_name.gsub(".", "/") + ".ad" # clean-up hardcodes
	lines = File.readlines(template_path)
	doc = Asciidoctor::Document.new(lines, {:backend => 'html5', :header_footer => true,
		:safe => Asciidoctor::SafeMode::SAFE, :attributes => {'linkcss!' => ''}
		})
	html_mail = doc.render()

	# send email
	mail = Mail.new do
	  from     'amitava@umich.edu'
	  to       'amitava@umich.edu'
	  subject  'Test email'
	  # body     html_mail
	  html_part do
	      content_type 'text/html; charset=UTF-8'
	      body html_mail
	  end
	end
	mail.delivery_method :sendmail
	mail.deliver
end

