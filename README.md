JumpCloud System Context API
================

* [Introduction](#introduction)
* [Authentication](#authentication)
* [Parameters](#parameters)
* [Data structures](#data-structures)
* [Routes](#routes)
* [Examples](#additional-examples)
* [Third party](#third-party)

### Introduction

The JumpCloud System Context API is a REST API for manipulating the system on which a JumpCloud Agent is installed.
To use the System Context API, you must first [create a JumpCloud account](https://console.jumpcloud.com/register/) and [add a system to be managed](https://console.jumpcloud.com/systems).
Once the JumpCloud Agent is installed, the JumpCloud-enabled system can now use the REST API within its own context.


### Authentication

To allow for secure access to the API, you must authenticate each API request.
The JumpCloud API uses [HTTP Signatures](http://tools.ietf.org/html/draft-cavage-http-signatures-00) to authenticate API requests. 
The HTTP Signatures sent with each request are similar to the signatures used by the Amazon Web Services REST API.
To help with the request-signing process, we have provided an [example bash script](/examples/shell/SigningExample.sh).


Here is a breakdown of the example script, with explanations...

The first thing the script does is extract the systemKey from the /opt/jc/jcagent.conf file.

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


### Parameters

|Parameter(s)|Description|Usage|
|---------|-----------------|-----|
|`limit` `skip`| `limit` will limit the returned results and `skip` will skip results.  | ` /api/tags?limit=5&skip=1` returns records 2 - 6 . |
|`sort`         | `sort` will sort results by the specified field name.                      | `/api/tags?sort=name&limit=5` returns tags sorted by name in ascending order. `/api/tags?sort=-name&limit=5` returns tags sorted by name in descending order. |
|`fields`       | `fields` is a space-separated string of field names to include or exclude from the result(s). | `/api/system/:id?fields=-patches -logins` |


### Data structures

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


### Routes

**NOTE: The :id url parameter must be associated to the system public key being used to sign API requests. Using an incorrect system id will result in a 401 Unauthorized error.**

|Resource|Description|
|--------|-----------|
|[GET /api/systems/:id](#get-apisystemsid)|Returns a single system record corresponding to the :id url parameter.|
|[PUT /api/systems/:id](#put-apisystemsid)|Updates the properties of the system.|
|[DELETE /api/systems/:id](#delete-apisystemsid)| Uninstalls the JumpCloud agent from the specified system and removes the system from the list of systems managed by JumpCloud.|


### GET /api/systems/:id

#### Parameters

|Parameter(s)|Description|
|---------|-----------------|
|`fields`      | restricts the fields returned in the system object |

#### Returns:

A single system object corresponding to the specified :id.

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

|Parameter(s)|Description|
|---------|-----------------|
|`fields`       | restricts the list of fields to be returned after updating the system object

#### Fields that may be updated

| Field                          | Data type |Allowed values| Description |
|--------------------------------|-----------|--------------|-------------|
| displayName                    | String    | *any string* | The name to display for a system in the JumpCloud UI. |
| allowSshPasswordAuthentication | Boolean   | *true/false* | If `true`, the system will allow SSH password authentication; if `false`, all password-based SSH authentication attempts will be rejected. |
| allowSshRootLogin              | Boolean   | *true/false* | If `true`, the `root` account will be allowed to login via SSH; if `false`, the root account will be denied access via SSH.
| allowMultiFactorAuthentication | Boolean   | *true/false* | If `true`, the multi-factor pam module will be enabled and users configured to use multi-factor authentication will be prompted for a second authentication factor.
| allowPublicKeyAuthentication   | Boolean   | *true/false* | If `true`, the system will allow JumpCloud-managed public keys to be used to authenticate users. |
| tags                           | Array     | *array of strings* | The array values should be the ids or names of the tag(s) with which the system should be associated. **NOTE: The tags sent with the update request will replace the existing tag associations.** |

#### Returns:

The updated system object.

Sample output (truncated)...

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
  "tags" : ["5266df0f9af46c0e724ef13e", "5266df229af46c0e724ef140"]
  ...
}

```


### DELETE /api/systems/:id

Requests sent to this route will uninstall the JumpCloud agent from the specified system and remove the system and its data from the list of JumpCloud-managed systems.

#### Parameters

None



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




