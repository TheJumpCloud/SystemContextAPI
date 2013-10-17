#!/bin/sh

now=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`;
signstr="GET /api/systems/525ee96f52e144993e000015 HTTP/1.1\ndate: ${now}"
signature=`printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n'` ;

curl -iv \
  -H "Accept: application/json" \
  -H "Date: ${now}" \
  -H "Authorization: Signature keyId=\"system/525ee96f52e144993e000015\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
  --url https://api.jumpcloud.com/api/systems/525ee96f52e144993e000015
