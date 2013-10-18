JumpCloud System Context API
================

* [Authentication](#Authentication)
* [Routes](#Routes)
* [Parameters and Data Structures](#Parameters)

### Introduction

The JumpCloud System Context API is a REST API for manipulating the system a JumpCloud Agent is installed on. 
To use the System Context API you must first [create a JumpCloud account](https://console.jumpcloud.com/register/) and [add a system to be managed](https://console.jumpcloud.com/systems).
From the system that has the JumpCloud Agent you can now use the REST API in the context of that system. 

<a id="Authentication" /></a>
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

Make the API call sending the signature has the Authorization header and the Date header with the same value that was used in the signing string.
This particular API request is simply requesting the entire system record. 

<a id="Routes"></a>
### Routes

**NOTE: The :id url parameter must be associated to the system public key being used to sign API requests. Using an incorrect system id will result in a 401 Unauthorized error.**

<table style="width : 100%">
  <thead>
    <tr>
      <td>
        <strong>Resource</strong>
      </td>
      <td>
        <strong>Description</strong>
      </td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <a href="#get-system">GET /api/systems/:id</a>
      </td>
      <td>
        Returns the system record specified by the :id url parameter.
      </td>
    </tr>
    
    <tr>
      <td>
        <a href="#put-system">PUT /api/systems/:id</a>
      </td>
      <td>
        Update properties of the system.
      </td>
    </tr>
    
    <tr>
      <td>
        <a href="#get-tags">GET /api/tags</a>
      </td>
      <td>
        Return tags for your organization. 
      </td>
    </tr>
    
    <tr>
      <td>
        <a href="#get-system-tags">GET /api/systems/:id/tags</a>
      </td>
      <td>
        Get the tags associated to a system.
      </td>
    </tr>
    
    <tr>
      <td>
        <a href="#put-system-tags">PUT /api/systems/:id/tags</a>
      </td>
      <td>
        Update the tags associated to a system.
      </td>
    </tr>
    
  </tbody>
</table>

<a id="Parameters"></a>
### Parameters and data structures

sdf sdf dsfs dffds df


<a href="#get-system-id"></a>

### GET /api/systems/:id 




