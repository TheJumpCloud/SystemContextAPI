This file is no longer maintained, for the most current documention on System Context please refer to the [JumpCloud API Documentation](https://docs.jumpcloud.com/1.0/authentication-and-authorization/system-context)

JumpCloud System Context API
================

* [Introduction](#introduction)
* [Supported Endpoints](#endpoints)
* [Authentication](#authentication)
* [Data structures](#data-structures)
* [Examples](#additional-examples)
* [Third party](#third-party)

### Introduction

The JumpCloud System Context API is an alternative way to authenticate with a subset of JumpCloud's REST APIs. Using this method a system can manage it's information and resource associations, allowing modern auto provisioning environments to scale as needed.

### Supported Endpoints 

The system context API can be used in conjunction with Systems endpoints found in the V1 API and certain System Group endpoints found in the v2 API. You can review our [API documention.](https://docs.jumpcloud.com/) for more details on these endpoints.

- A system may fetch, alter, and delete metatdata about itself, including manipulating a system's Tag and Systemuser associations, 
  - `/api/systems/{system_id}` | `GET` `PUT`
- A system may delete itself from your JumpCloud organization
  - `/api/systems/{system_id}` | `DELETE`
- A system may fetch it's direct resource assocations under v2 (Groups)
  - `/api/v2/systems/{system_id}/memberof` | `GET`
  - `/api/v2/systems/{system_id}/associations` | `GET`
  - `/api/v2/systems/{system_id}/users` | `GET`
- A system may alter it's direct resource assocations under v2 (Groups)
  - `/api/v2/systems/{system_id}/associations` | `POST`
- A system may alter it's System Group associations
  - `/api/v2/systemgroups/{systemgroup_id}` | `POST`
    - _NOTE_ If a system attempts to alter the system group membership of a different system the request will be rejected

* Note that the Groups endpoints are documented under the V2 section of our 
[API Documentation.](https://docs.jumpcloud.com/2.0/groups) 
* Note that the Systems endpoints are documented under the V1 section of our [API Documentation.](https://docs.jumpcloud.com/1.0/systems)

### Response Codes

If endpoints other than those described above are called using the System Context API the server will return a `401` response.

### Authentication

To allow for secure access to the API, you must authenticate each API request.
The System Context API uses [HTTP Signatures](http://tools.ietf.org/html/draft-cavage-http-signatures-00) to authenticate API requests. 
The HTTP Signatures sent with each request are similar to the signatures used by the Amazon Web Services REST API.
To help with the request-signing process, we have provided an [example bash script](/examples/shell/SigningExample.sh). You must be root, or have permissions to access the contents of the `/opt/jc` directory to generate a signature.


Here is a breakdown of the example script, with explanations.

The first thing the script does is extract the systemKey from the JSON formatted `/opt/jc/jcagent.conf` file.

```
#!/bin/bash

conf="`cat /opt/jc/jcagent.conf`"
regex="systemKey\":\"(\w+)\""

if [[ $conf =~ $regex ]] ; then
  systemKey="${BASH_REMATCH[1]}"
fi
```

Then the script retrieves the current date in the correct format.

```
now=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`;
```

Next we build a signing string to demonstrate the expected signature format. The signed string must consist of the [request-line](http://tools.ietf.org/html/rfc2616#page-35) and the date header, separated by a newline character.

```
signstr="GET /api/systems/${systemKey} HTTP/1.1\ndate: ${now}"
```

The next step is to calculate and apply the signature. This is a two-step process:

1. Create a signature from the signing string using the JumpCloud Agent private key: ``printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key``
1. Then Base64-encode the signature string and trim off the newline characters: ``| openssl enc -e -a | tr -d '\n'``

The combined steps above result in:

```
signature=`printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n'` ;
```

Finally, we make sure the API call sending the signature has the same Authorization header and Date header values that were used in the signing string.
This example API request simply requests the entire system record.

```
curl -iq \
  -H "Accept: application/json" \
  -H "Date: ${now}" \
  -H "Authorization: Signature keyId=\"system/${systemKey}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
  --url https://console.jumpcloud.com/api/systems/${systemKey}
```

#### Input data

All PUT methods should use the HTTP Content-Type header with a value of 'application/json'. PUT methods are used for updating a record.

The following example demonstrates how to update the `displayName` of the system.

```
signstr="PUT /api/systems/${systemKey} HTTP/1.1\ndate: ${now}"
signature=`printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n'` ;

curl -iq \
  -d "{\"displayName\" : \"updated-system-name-1\"}" \
  -X "PUT" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Date: ${now}" \
  -H "Authorization: Signature keyId=\"system/${systemKey}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
  --url https://console.jumpcloud.com/api/systems/${systemKey}
```


#### Output data

All results will be formatted as [JSON](www.json.org).

Here is an abbreviated example of response output:

```
{
  "__v": 0,
  "_id": "525ee96f52e144993e000015",
  "agentServer": "lappy386",
  "agentVersion": "0.9.42",
  "arch": "x86_64",
  "connectionKey": "127.0.0.1_51812",
  "displayName": "ubuntu-1204",
  "firstContact": "2013-10-16T19:30:55.611Z",
  "hostname": "ubuntu-1204" 
  ...
```


### Additional Examples

#### Signing authentication example

This example demonstrates how to make an authenticated request to the System Context API (explained previously.)
The API request simply requests a fetch of the JumpCloud record for this system.

[SigningExample.sh](/examples/shell/SigningExample.sh)


#### Shutdown hook 

This example demonstrates how to make requests to the API on system shutdown.
Using an init.d script registered at run level 0, you can call the System Context API as the system is shutting down.

[Instance-shutdown-initd](/examples/instance-shutdown-initd) is an example of an init.d script that only runs at system shutdown.

After customizing the [instance-shutdown-initd](/examples/instance-shutdown-initd) script, you should install it on the system(s) running the JumpCloud agent...

1. Copy the modified [instance-shutdown-initd](/examples/instance-shutdown-initd) to `/etc/init.d/instance-shutdown`
2. On Ubuntu systems, run `update-rc.d instance-shutdown defaults`. On RedHat/CentOS systems, run `chkconfig --add instance-shutdown`


### Third party

#### Chef cookbooks

[https://github.com/nshenry03/jumpcloud](https://github.com/nshenry03/jumpcloud)

[https://github.com/cjs226/jumpcloud](https://github.com/cjs226/jumpcloud)




