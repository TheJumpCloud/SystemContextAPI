#!/usr/bin/python
import requests
import json
import sys
import pprint
pp = pprint.PrettyPrinter(indent=4)
##########################################################################
# MAIN
#{"filter": [{"hostname" : "ip-192-168-1-199"}]}' 
#payload='"filter": "[{"hostname" : "ip-192-168-1-199"}]"'
payload='{"filter": [{"hostname" : "ip-192-168-1-199"}]}'
search_url = 'https://console.jumpcloud.com/api/search/systems/'
headers={
	'Accept' : 'application/json',
	'Content-Type' : 'application/json',
	#'User-Agent': 'curl/7.35.0',
	'Host' : 'console.jumpcloud.com',
	'x-api-key' : 'key'
}
req = requests.Request('POST',search_url,headers=headers,data=payload)
prepared = req.prepare()
def pretty_print_POST(req):
    """
    At this point it is completely built and ready
    to be fired; it is "prepared".

    However pay attention at the formatting used in 
    this function because it is programmed to be pretty 
    printed and may differ from the actual request.
    """
    print('{}\n{}\n{}\n\n{}'.format(
        '-----------START-----------',
        req.method + ' ' + req.url,
        '\n'.join('{}: {}'.format(k, v) for k, v in req.headers.items()),
        req.body,
    ))

pretty_print_POST(prepared)
s = requests.Session()
resp=s.send(prepared)
print vars(resp)
