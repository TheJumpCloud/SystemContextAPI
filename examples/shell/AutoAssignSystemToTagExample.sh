#!/bin/bash

##
## This example demonstrates how to auto assign a system to a tag
## using the System Context API. This script should be run after
## running the Kickstart script [https://kickstart.jumpcloud.com/Kickstart]
## and can be used in your chef cookbooks or puppet manifests.
##

# check if the jumpcloud agent conf has an assigned systemKey
hasSystemKey() {
  cat /opt/jc/jcagent.conf | grep systemKey
}

# wait for the jumpcloud agent to complete system registration
waitForSystemToRegister() {
  a=`hasSystemKey`
  while [ "$a" == "" ];  do
    #echo "waiting for agent to register"
    sleep 5
    a=`hasSystemKey`
  done
}

waitForSystemToRegister

# Parse the systemKey from the conf file.
# The conf file is JSON and can be parsed using JSON.parse() in a supported language.
conf="`cat /opt/jc/jcagent.conf`"
regex="systemKey\":\"(\w+)\""

if [[ ${conf} =~ $regex ]] ; then
  systemKey="${BASH_REMATCH[1]}"
fi

# Get the current time.
now=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`;

# create the string to sign from the request-line and the date
signstr="PUT /api/systems/${systemKey} HTTP/1.1\ndate: ${now}"

# create the signature
signature=`printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n'` ;

# assign the system to the all-servers and web-servers tag.
# NOTE: The tags must already exist in your jumpcloud account. This api call will not create the tags.
curl -iq \
  -d "{ \"tags\" : [\"all-servers\", \"web-servers\"]}" \
  -X "PUT" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Date: ${now}" \
  -H "Authorization: Signature keyId=\"system/${systemKey}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
  --url https://console.jumpcloud.com/api/systems/${systemKey}