JumpCloud System Context API
================

* [Introduction](#introduction)
* [Authentication](#authentication)
* [Parameters](#parameters)
* [Data structures](#data-structures)
* [Routes](#routes)

### Introduction

The JumpCloud System Context API is a REST API for manipulating the system a JumpCloud Agent is installed on. 
To use the System Context API you must first [create a JumpCloud account](https://console.jumpcloud.com/register/) and [add a system to be managed](https://console.jumpcloud.com/systems).
From the system that has the JumpCloud Agent you can now use the REST API in the context of that system. 


### Authentication

To allow for secure access to the API you must authentication each API request. 
The JumpCloud API uses [HTTP Signatures](http://tools.ietf.org/html/draft-cavage-http-signatures-00) to authenticate API requests. 
HTTP Signatues is similar to the Amazon Web Services REST API where you send a signature with each request.
To help with the request signing process there is an [example bash script](/shell/SigningExample.sh). 


Let's have a look...

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
curl -iq \
  -H "Accept: application/json" \
  -H "Date: ${now}" \
  -H "Authorization: Signature keyId=\"system/${systemKey}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
  --url https://api.jumpcloud.com/api/systems/${systemKey}
```

Make the API call sending the signature has the Authorization header and the Date header with the same value that was used in the signing string.
This particular API request is simply requesting the entire system record. 

### Parameters

|Parameter(s)|Description|Usage|
|---------|-----------------|-----|
|`limit` `skip`| `limit` will limit the returned results and `skip` will skip results.  | ` /api/tags?limit=5&skip=1` return records 2 - 6 . |
|`sort`         | `sort` will sort results by the given field name.                      | `/api/tags?sort=name&limit=5` return tags sorted ascending by name. `/api/tags?sort=-name&limit=5` return tags sorted descending by name. |
|`fields`       | `fields` is a space separated string of field names to include or exclude from the returning result(s). | `/api/system/:id?fields=-patches -logins` |


### Data structures

#### Input data

All PUT methods should use the HTTP Content-Type header with a value of application/json for updating record. 

Here is an example of updating the `displayName` of the system. 

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
  --url https://api.jumpcloud.com/api/systems/${systemKey}


```


#### Output data

All returned data will be [JSON](www.json.org). 

Here is an abbreviated example of output.

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


### Routes

**NOTE: The :id url parameter must be associated to the system public key being used to sign API requests. Using an incorrect system id will result in a 401 Unauthorized error.**

|Resource|Description|
|--------|-----------|
|[GET /api/systems/:id](#get-apisystemsid)|Returns a single system record specified by the :id url parameter.|
|[PUT /api/systems/:id](#put-apisystemsid)|Update properties of the system.|
|[DELETE /api/systems/:id](#delete-apisystemsid)| Delete system and uninstall agent.|

### GET /api/systems/:id

#### Parameters

`fields` restrict the fields returned in the system object

#### Returns

Returns a single system object.

Sample output...

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
  "hostname": "ubuntu-1204",
  "lastContact": "2013-10-18T15:26:34.240Z",
  "lastContactSystemTime": "2013-10-18T15:23:34.377Z",
  "lastSnapshot": "2013-10-18T15:16:30.921Z",
  "lastSystemInfoUpdate": "2013-10-18T15:23:34.316Z",
  "organization": "525764a201edf28e43000021",
  "os": "Ubuntu",
  "remoteIP": "127.0.0.1",
  "snapshotDuration": 86400000,
  "systemTimezone": 0,
  "templateName": "ubuntu-12.04-x86_64",
  "updateAlarms": false,
  "version": "12.04.3",
  "patchAlarms": [],
  "dailyEmails": [],
  "tags" : ["5266df0f9af46c0e724ef13e", "5266df229af46c0e724ef140"],
  "connectionHistory": [
    "2013-10-16T19:30:55.605Z",
    "2013-10-16T19:32:05.900Z",
    "2013-10-16T22:18:07.138Z",
    "2013-10-16T22:18:07.612Z",
    "2013-10-18T15:16:25.863Z",
    "2013-10-18T15:16:26.406Z",
    "2013-10-18T15:23:34.058Z",
    "2013-10-18T15:23:34.111Z"
  ],
  "allowPublicKeyAuthentication": true,
  "allowMultiFactorAuthentication": false,
  "allowSshRootLogin": false,
  "allowSshPasswordAuthentication": false,
  "patches": {
    "updateCount": 4,
    "securityUpdateCount": 4,
    "criticalUpdateCnt": 0,
    "uniquePackages": [
      {
        "program": "rpcbind",
        "dependencyCount": 2
      },
      {
        "program": "file-rc",
        "dependencyCount": 3
      },
      {
        "program": "initscripts",
        "dependencyCount": 6
      },
      {
        "program": "insserv",
        "dependencyCount": 3
      },
      {
        "program": "libc6",
        "dependencyCount": 103
      }

      ... truncated for brevity
      
    ],
    "netProgramPackages": [
      {
        "program": "rpcbind",
        "file": "/sbin/rpcbind",
        "package": "rpcbind"
      },
      {
        "program": "dhclient3",
        "file": "/sbin/dhclient3",
        "package": "isc-dhcp-client"
      },
      {
        "program": "rpc.statd",
        "file": "/sbin/rpc.statd",
        "package": "nfs-common"
      },
      {
        "program": "sshd",
        "file": "/usr/sbin/sshd",
        "package": "openssh-server"
      }
    ],
    "netProgramNoPackageFound": [],
    "netProgramNoFileFound": [
      {
        "program": "jcagent",
        "cnt": 1
      }
    ],
    "packageUpdates": [
      {
        "package": "accountsservice",
        "currentVersion": " 0.6.15-2ubuntu9.6 ",
        "newVersion": " 0.6.15-2ubuntu9.6.1",
        "security": true
      },
      {
        "package": "gnupg",
        "currentVersion": " 1.4.11-3ubuntu2.3 ",
        "newVersion": " 1.4.11-3ubuntu2.4",
        "security": true
      },
      {
        "package": "gpgv",
        "currentVersion": " 1.4.11-3ubuntu2.3 ",
        "newVersion": " 1.4.11-3ubuntu2.4",
        "security": true
      },
      {
        "package": "libaccountsservice0",
        "currentVersion": " 0.6.15-2ubuntu9.6 ",
        "newVersion": " 0.6.15-2ubuntu9.6.1",
        "security": true
      }
    ]
  },
  "sshdParams": [
    {
      "val": "22",
      "name": "Port"
    },
    {
      "val": "2",
      "name": "Protocol"
    },
    {
      "val": "no",
      "name": "PermitRootLogin"
    },
    {
      "val": "no",
      "name": "PasswordAuthentication"
    },
    {
      "val": "yes",
      "name": "UsePAM"
    }
    
    ... truncated for brevity
    
  ],
  "active": true,
  "networkInterfaces": [
    {
      "name": "lo",
      "internal": true,
      "family": "IPv4",
      "address": "127.0.0.1"
    },
    {
      "name": "lo",
      "internal": true,
      "family": "IPv6",
      "address": "::1"
    },
    {
      "name": "eth0",
      "internal": false,
      "family": "IPv4",
      "address": "10.0.2.15"
    },
    {
      "name": "eth0",
      "internal": false,
      "family": "IPv6",
      "address": "fe80::a00:27ff:febc:a596"
    }
  ],
  "created": "2013-10-16T19:30:55.572Z",
  "sshRootEnabled": false,
  "sshPassEnabled": false,
  "patchAlarmCount": 0,
  "commandAlarmCount": 1,
  "loginAlarmCount": 1,
  "id": "525ee96f52e144993e000015"
}

```


### PUT /api/systems/:id

#### Parameters

`fields` restrict the returning fields of the updated system object

#### Updatable fields

| Field                          | Data type |Allowed values| Description |
|--------------------------------|-----------|--------------|-------------|
| displayName                    | String    | *any string* | The name to display in the UI for a system. |
| allowSshPasswordAuthentication | Boolean   | *true/false* | If `true` the system will allow ssh password authentication, if `false` all password authentication attempts will be rejected |
| allowSshRootLogin              | Boolean   | *true/false* | If `true` the `root` account will be allowed to login via ssh, if `false` the root account will be denied access via ssh.
| allowMultiFactorAuthentication | Boolean   | *true/false* | If `true` the multifactor pam module will be enabled and users configured to use multi factor auth will be able take advantage.
| allowPublicKeyAuthentication   | Boolean   | *true/false* | If `true` the system will allow JumpCloud managed public keys to be used to authenticate users. |
| tags                           | Array     | *array of strings* | The array values should be the ids, or names, of the tag(s) that you want the system to be associated with. The tags passed will replace any existing tags with the supplied list. |

#### Returns

Returns a single system object.

Sample output...

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
  
  ... truncated for brevity
  
}

```


### DELETE /api/systems/:id

This command will uninstall the agent on the system, then will remove the system and its data once the agent has been uninstalled.



