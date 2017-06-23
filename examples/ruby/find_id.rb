#!/usr/bin/ruby
require 'net/http'
require 'json'
require 'uri'
require 'yaml'
require 'trollop'
opts = Trollop::options do
    #opt :conf, "file of fogrc settings http://fog.io/about/getting_started.html", :type => :string, :required => true
    opt :hostname, "The hostname to find", :type => :string, :required => true
end


config = YAML.load_file('./conf/jumpcloud.conf')
uri = URI.parse("https://console.jumpcloud.com")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
payload="{\"filter\": [{\"hostname\" : \"#{opts[:hostname]}\"}]}"
request = Net::HTTP::Post.new("/api/search/systems")
request.initialize_http_header({"Accept" => "application/json"})
request.add_field('Content-Type', 'application/json')
#request.add_field('Accept', 'application/json')
request.add_field('Host', uri.host)
request.add_field('x-api-key', config['key'])
request.body=payload

#http.set_debug_output($stdout)
res = http.request(request)
result = JSON.parse(res.body)
if result['totalCount'] == 1
	result['results'].each do |hash|
		hash.each do |key, value|
			if key == 'id'
				puts value
			end
		end
	end
else
	"puts got more than 1 or 0 results"
end
