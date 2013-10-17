JumpCloud System Context API
================

## Introduction

The JumpCloud System Context API is a REST API for manipulating the system the JumpCloud Agent is installed on. 
To use the System Context API you must first [create a JumpCloud account](https://console.jumpcloud.com/register/) and [add a system to be managed](https://jumpcloud.com/systems).
From the system that has the JumpCloud Agent you can now use the REST API in the context of that system. 

### Authentication

To allow for secure access to the API you must authentication each API request. 
The JumpCloud API uses [HTTP Signatures](http://tools.ietf.org/html/draft-cavage-http-signatures-00) to authenticate API requests. 
HTTP Signatues is similar to the Amazon Web Services REST API where you send a signature with each request.
To help with the request signing process there is an [example bash script](/shell/SigningExample.sh). Let's have a look at it...

```
#!/bin/bash

conf="`cat /opt/jc/jcagent.conf`"
regex="systemKey\":\"(\w+)\""

if [[ $conf =~ $regex ]] ; then
  systemKey="${BASH_REMATCH[1]}"
fi
```

Extract the systemKey from the /opt/jc/jcagent.conf file.

```
now=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`;
```

Get the date in the correct format.

```
signstr="GET /api/systems/${systemKey} HTTP/1.1\ndate: ${now}"
```

Build a string to sign. The signed string must consist if the [request-line](http://tools.ietf.org/html/rfc2616#page-35) and the date header separated by a new line character.

```
signature=`printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n'` ;
```

Create the signed string. The steps here are...

1. Create a signature from the signing string using the JumpCloud Agent private key ``printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key``
1. Then base64 encode the signature string and trim off the new-line chars ``| openssl enc -e -a | tr -d '\n'``

```
curl -iv \
  -H "Accept: application/json" \
  -H "Date: ${now}" \
  -H "Authorization: Signature keyId=\"system/${systemKey}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
  --url https://api.jumpcloud.com/api/systems/${systemKey}
```

Make the API call sending the signature has the Authorization header and the Date header with the same value what was used in the signing string.
