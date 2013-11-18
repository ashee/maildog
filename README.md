Maildog
=======
This project is a REST oriented service that allow REST clients to send rich emails.
It expects JSON data in an http post. This is a sinatra application that uses
sidekiq to process mail jobs asynchronously. The application has been tested with
J2EE environment using JRuby. 

Pre-requisites
==============
1. Install jdk 1.7 
2. Install JRuby 1.7.6
3. Reddis 2.6.16
4. Pre-configured Mail Transfer Agent (MTA). For my development, I am using postfix 
that comes prebundled in OSX 10.8 MBP. To start postfix, run

```bash
$ sudo postfix start
```

Application setup
=================
1. md is a git project. Git clone or simply copy this folder over.
2. Issue the following command

```bash
$ cd md
$ bundle install
```
3. Run the web-frontend on port 8080 (or your port of choice)

```bash
$ trinidad -p 8080
```
4. Start redis-server (sidekiq depends on this service)

```bash
$ redis-server 
```

5. Run the sidekiq worker process

```bash
$ sidekiq -r 
```
The sidekiq dashboard is available as a web-application at http://127.0.0.1:8080/sidekiq

Test applications
=================
1. Test that the web frontend works

```bash
amitava:md amitava$ curl -i http://127.0.0.1:8080/
HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
X-Content-Type-Options: nosniff
Content-Type: text/plain;charset=utf-8
Content-Length: 2045
Date: Mon, 18 Nov 2013 15:26:39 GMT

====== REQUEST ========
#<Sinatra::Request:0x7937c9b2
 @env=
  {"rack.version"=>[1, 2],
   "rack.input"=>#<JRuby::Rack::Input:0x0bf50edf>,
   "rack.errors"=>
    #<JRuby::Rack::ServletLog:0x05a3589b
     @context=
      #<Java::OrgJrubyRackServlet::DefaultServletRackContext:0x1e66fc2d>>,
   "rack.url_scheme"=>"http",
   "rack.multithread"=>true,
   "rack.multiprocess"=>false,
   "rack.run_once"=>false,
   "java.servlet_request"=>
    #<Java::OrgApacheCatalinaConnector::RequestFacade:0x62c5458b>,
   "java.servlet_response"=>
    #<Java::OrgApacheCatalinaConnector::ResponseFacade:0x558db56>,
   "java.servlet_context"=>
    #<Java::OrgApacheCatalinaCore::ApplicationContextFacade:0x69ca598d>,
   "jruby.rack.version"=>"1.1.13.2",
   "jruby.rack.jruby.version"=>"1.7.6",
   "jruby.rack.rack.release"=>"1.5",
   "PATH_INFO"=>"/",
   "QUERY_STRING"=>"",
   "REMOTE_ADDR"=>"127.0.0.1",
   "REMOTE_HOST"=>"127.0.0.1",
   "REMOTE_USER"=>"",
   "REQUEST_METHOD"=>"GET",
   "REQUEST_URI"=>"/",
   "SCRIPT_NAME"=>"",
   "SERVER_NAME"=>"127.0.0.1",
   "SERVER_PORT"=>"8080",
   "SERVER_SOFTWARE"=>"Apache Tomcat/7.0.41",
   "HTTP_USER_AGENT"=>
    "curl/7.24.0 (x86_64-apple-darwin12.0) libcurl/7.24.0 OpenSSL/0.9.8y zlib/1.2.5",
   "HTTP_HOST"=>"127.0.0.1:8080",
   "HTTP_ACCEPT"=>"*/*",
   "sinatra.commonlogger"=>true,
   "rack.logger"=>
    #<Logger:0x03b7e080
     @default_formatter=#<Logger::Formatter:0x54748db1 @datetime_format=nil>,
     @formatter=nil,
     @level=1,
     @logdev=
      #<Logger::LogDevice:0x76e56917
       @dev=
        #<JRuby::Rack::ServletLog:0x05a3589b
         @context=
          #<Java::OrgJrubyRackServlet::DefaultServletRackContext:0x1e66fc2d>>,
       @filename=nil,
       @mutex=
        #<Logger::LogDevice::LogDeviceMutex:0x40a4d015
         @mon_count=0,
         @mon_mutex=#<Mutex:0x045933db>,
         @mon_owner=nil>,
       @shift_age=nil,
       @shift_size=nil>,
     @progname=nil>,
   "rack.request.query_string"=>"",
   "rack.request.query_hash"=>{},
   "sinatra.route"=>"GET /"},
 @params={}>
amitava:md amitava$ curl -i http://127.0.0.1:8080/
```

2. Send a test mail job

```bash
amitava:md amitava$ curl -i -X POST -d @data.json http://127.0.0.1:8080/mail
HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Content-Type: text/html;charset=utf-8
Content-Length: 24
Date: Mon, 18 Nov 2013 15:29:11 GMT

77be1af874897c48f9bb5670amitava:md amitava$
```

Templates
=========
The mail templates are kept under the templates folder with a particular naming convention.
For example, the sample event is under
template/admissions/ApplicationReceived.ad

The client asks for a specific template via the event attribute inside the json.
Here is the sample data from data.json

```json
{
	"events" : [
		{ 
			"event" : "admissions.ApplicationReceived"
			...
			...
		}
	]
}
```

The application replaces the dots with file path separator and appends ".ad" as filename suffix. 
In this sample, we derive the template pathname as
templates/admissions/ApplicationReceived.ad

This template is assumed to have variables in the form {{some.arbitrary.attribute}}.
This syntax is from mustache template engine. Maildog will run it first through mustache
to expand template variables which is then assumed to expand to an asciidoctor formatted
document. This is then run through asciidoctor engine to generate the final email in html
format.


