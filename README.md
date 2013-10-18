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
|[GET /api/tags](#get-apitags)|Return tags for your organization.|
|[GET /api/systems/:id/tags](#get-apisystemsidtags)|Get the tags associated to a system.|
|[PUT /api/systems/:id/tags](#put-apisystemsidtags)|Update the tags associated to a system.|


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
      },
      {
        "program": "libtirpc1",
        "dependencyCount": 3
      },
      {
        "program": "libwrap0",
        "dependencyCount": 4
      },
      {
        "program": "lsb-base",
        "dependencyCount": 8
      },
      {
        "program": "upstart-job",
        "dependencyCount": 10
      },
      {
        "program": "dpkg",
        "dependencyCount": 12
      },
      {
        "program": "coreutils",
        "dependencyCount": 5
      },
      {
        "program": "debianutils",
        "dependencyCount": 5
      },
      {
        "program": "mount",
        "dependencyCount": 2
      },
      {
        "program": "mountall",
        "dependencyCount": 4
      },
      {
        "program": "passwd",
        "dependencyCount": 5
      },
      {
        "program": "sysv-rc",
        "dependencyCount": 3
      },
      {
        "program": "sysvinit-utils",
        "dependencyCount": 4
      },
      {
        "program": "upstart",
        "dependencyCount": 3
      },
      {
        "program": "install-info",
        "dependencyCount": 6
      },
      {
        "program": "libacl1",
        "dependencyCount": 3
      },
      {
        "program": "libattr1",
        "dependencyCount": 3
      },
      {
        "program": "libselinux1",
        "dependencyCount": 16
      },
      {
        "program": "libbz2-1.0",
        "dependencyCount": 2
      },
      {
        "program": "tar",
        "dependencyCount": 2
      },
      {
        "program": "xz-utils",
        "dependencyCount": 2
      },
      {
        "program": "zlib1g",
        "dependencyCount": 10
      },
      {
        "program": "multiarch-support",
        "dependencyCount": 60
      },
      {
        "program": "libc-bin",
        "dependencyCount": 2
      },
      {
        "program": "libgcc1",
        "dependencyCount": 2
      },
      {
        "program": "tzdata",
        "dependencyCount": 3
      },
      {
        "program": "gcc-4.6-base",
        "dependencyCount": 2
      },
      {
        "program": "debconf",
        "dependencyCount": 12
      },
      {
        "program": "debconf-2.0",
        "dependencyCount": 10
      },
      {
        "program": "perl-base",
        "dependencyCount": 3
      },
      {
        "program": "liblzma5",
        "dependencyCount": 2
      },
      {
        "program": "sensible-utils",
        "dependencyCount": 2
      },
      {
        "program": "ncurses-bin",
        "dependencyCount": 2
      },
      {
        "program": "sed",
        "dependencyCount": 2
      },
      {
        "program": "libtinfo5",
        "dependencyCount": 9
      },
      {
        "program": "libblkid1",
        "dependencyCount": 4
      },
      {
        "program": "libmount1",
        "dependencyCount": 2
      },
      {
        "program": "libuuid1",
        "dependencyCount": 3
      },
      {
        "program": "libpam-modules",
        "dependencyCount": 4
      },
      {
        "program": "libpam0g",
        "dependencyCount": 5
      },
      {
        "program": "libdb5.1",
        "dependencyCount": 4
      },
      {
        "program": "libpam-modules-bin",
        "dependencyCount": 2
      },
      {
        "program": "libdbus-1-3",
        "dependencyCount": 5
      },
      {
        "program": "libnih-dbus1",
        "dependencyCount": 3
      },
      {
        "program": "libnih1",
        "dependencyCount": 4
      },
      {
        "program": "libplymouth2",
        "dependencyCount": 3
      },
      {
        "program": "libudev0",
        "dependencyCount": 7
      },
      {
        "program": "makedev",
        "dependencyCount": 2
      },
      {
        "program": "plymouth",
        "dependencyCount": 2
      },
      {
        "program": "udev",
        "dependencyCount": 5
      },
      {
        "program": "libpng12-0",
        "dependencyCount": 2
      },
      {
        "program": "base-passwd",
        "dependencyCount": 2
      },
      {
        "program": "initramfs-tools",
        "dependencyCount": 4
      },
      {
        "program": "libdrm-intel1",
        "dependencyCount": 2
      },
      {
        "program": "libdrm-nouveau1a",
        "dependencyCount": 2
      },
      {
        "program": "libdrm-radeon1",
        "dependencyCount": 2
      },
      {
        "program": "libdrm2",
        "dependencyCount": 5
      },
      {
        "program": "busybox-initramfs",
        "dependencyCount": 2
      },
      {
        "program": "cpio",
        "dependencyCount": 2
      },
      {
        "program": "findutils",
        "dependencyCount": 2
      },
      {
        "program": "initramfs-tools-bin",
        "dependencyCount": 2
      },
      {
        "program": "klibc-utils",
        "dependencyCount": 2
      },
      {
        "program": "module-init-tools",
        "dependencyCount": 3
      },
      {
        "program": "util-linux",
        "dependencyCount": 4
      },
      {
        "program": "libklibc",
        "dependencyCount": 2
      },
      {
        "program": "adduser",
        "dependencyCount": 5
      },
      {
        "program": "libglib2.0-0",
        "dependencyCount": 2
      },
      {
        "program": "procps",
        "dependencyCount": 3
      },
      {
        "program": "libelf1",
        "dependencyCount": 2
      },
      {
        "program": "libffi6",
        "dependencyCount": 2
      },
      {
        "program": "libpcre3",
        "dependencyCount": 2
      },
      {
        "program": "libncurses5",
        "dependencyCount": 3
      },
      {
        "program": "libncursesw5",
        "dependencyCount": 2
      },
      {
        "program": "ifupdown",
        "dependencyCount": 2
      },
      {
        "program": "iproute",
        "dependencyCount": 3
      },
      {
        "program": "libslang2",
        "dependencyCount": 2
      },
      {
        "program": "libpciaccess0",
        "dependencyCount": 2
      },
      {
        "program": "libgssglue1",
        "dependencyCount": 3
      },
      {
        "program": "isc-dhcp-client",
        "dependencyCount": 1
      },
      {
        "program": "isc-dhcp-common",
        "dependencyCount": 2
      },
      {
        "program": "nfs-common",
        "dependencyCount": 1
      },
      {
        "program": "libcap2",
        "dependencyCount": 2
      },
      {
        "program": "libcomerr2",
        "dependencyCount": 10
      },
      {
        "program": "libdevmapper1.02.1",
        "dependencyCount": 3
      },
      {
        "program": "libevent-2.0-5",
        "dependencyCount": 2
      },
      {
        "program": "libkeyutils1",
        "dependencyCount": 3
      },
      {
        "program": "libkrb5-3",
        "dependencyCount": 4
      },
      {
        "program": "libnfsidmap2",
        "dependencyCount": 2
      },
      {
        "program": "ucf",
        "dependencyCount": 2
      },
      {
        "program": "dmsetup",
        "dependencyCount": 2
      },
      {
        "program": "libk5crypto3",
        "dependencyCount": 3
      },
      {
        "program": "libkrb5support0",
        "dependencyCount": 4
      },
      {
        "program": "libldap-2.4-2",
        "dependencyCount": 2
      },
      {
        "program": "libgcrypt11",
        "dependencyCount": 3
      },
      {
        "program": "libgnutls26",
        "dependencyCount": 2
      },
      {
        "program": "libgssapi3-heimdal",
        "dependencyCount": 2
      },
      {
        "program": "libsasl2-2",
        "dependencyCount": 2
      },
      {
        "program": "libgpg-error0",
        "dependencyCount": 2
      },
      {
        "program": "libp11-kit0",
        "dependencyCount": 2
      },
      {
        "program": "libtasn1-3",
        "dependencyCount": 2
      },
      {
        "program": "libasn1-8-heimdal",
        "dependencyCount": 5
      },
      {
        "program": "libhcrypto4-heimdal",
        "dependencyCount": 5
      },
      {
        "program": "libheimntlm0-heimdal",
        "dependencyCount": 2
      },
      {
        "program": "libkrb5-26-heimdal",
        "dependencyCount": 3
      },
      {
        "program": "libroken18-heimdal",
        "dependencyCount": 8
      },
      {
        "program": "libheimbase1-heimdal",
        "dependencyCount": 3
      },
      {
        "program": "libhx509-5-heimdal",
        "dependencyCount": 2
      },
      {
        "program": "libsqlite3-0",
        "dependencyCount": 2
      },
      {
        "program": "libwind0-heimdal",
        "dependencyCount": 3
      },
      {
        "program": "openssh-server",
        "dependencyCount": 1
      },
      {
        "program": "libgssapi-krb5-2",
        "dependencyCount": 3
      },
      {
        "program": "libpam-runtime",
        "dependencyCount": 2
      },
      {
        "program": "libssl1.0.0",
        "dependencyCount": 3
      },
      {
        "program": "openssh-client",
        "dependencyCount": 2
      },
      {
        "program": "libedit2",
        "dependencyCount": 2
      },
      {
        "program": "libbsd0",
        "dependencyCount": 2
      }
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
      "val": "/etc/ssh/ssh_host_rsa_key",
      "name": "HostKey"
    },
    {
      "val": "/etc/ssh/ssh_host_dsa_key",
      "name": "HostKey"
    },
    {
      "val": "/etc/ssh/ssh_host_ecdsa_key",
      "name": "HostKey"
    },
    {
      "val": "yes",
      "name": "UsePrivilegeSeparation"
    },
    {
      "val": "3600",
      "name": "KeyRegenerationInterval"
    },
    {
      "val": "768",
      "name": "ServerKeyBits"
    },
    {
      "val": "AUTH",
      "name": "SyslogFacility"
    },
    {
      "val": "INFO",
      "name": "LogLevel"
    },
    {
      "val": "120",
      "name": "LoginGraceTime"
    },
    {
      "val": "yes",
      "name": "StrictModes"
    },
    {
      "val": "yes",
      "name": "RSAAuthentication"
    },
    {
      "val": "yes",
      "name": "PubkeyAuthentication"
    },
    {
      "val": "yes",
      "name": "IgnoreRhosts"
    },
    {
      "val": "no",
      "name": "RhostsRSAAuthentication"
    },
    {
      "val": "no",
      "name": "HostbasedAuthentication"
    },
    {
      "val": "no",
      "name": "PermitEmptyPasswords"
    },
    {
      "val": "no",
      "name": "ChallengeResponseAuthentication"
    },
    {
      "val": "yes",
      "name": "X11Forwarding"
    },
    {
      "val": "10",
      "name": "X11DisplayOffset"
    },
    {
      "val": "no",
      "name": "PrintMotd"
    },
    {
      "val": "yes",
      "name": "PrintLastLog"
    },
    {
      "val": "yes",
      "name": "TCPKeepAlive"
    },
    {
      "val": "LANG LC_*",
      "name": "AcceptEnv"
    },
    {
      "val": "sftp /usr/lib/openssh/sftp-server",
      "name": "Subsystem"
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
| agentBoundMessages             | Boolean   | 

#### Returns

Returns a single system object.

Sample output...


### GET /api/tags 


### GET /api/systems/:id/tags


### PUT /api/systems/:id/tags

