#!/bin/bash

if [ ${#} != 2 ]; then
  echo "usage: ./create-userdata-bundle.sh <shutdown-init-script> <connect-key>"
  exit 1
fi

initFile=`base64 -w 0 $1`
connectKey=$2

instanceShutdown=`cat cloud-init/instance-shutdown.tmpl`
echo "${instanceShutdown/<INIT_FILE>/$initFile}" > instance-shutdown.txt

agentInstall=`cat cloud-init/jumpcloud-agent.tmpl`
echo "${agentInstall/<YOUR_CONNECT_KEY>/$connectKey}" > jumpcloud-agent.txt

write-mime-multipart --output=userdata.txt instance-shutdown.txt jumpcloud-agent.txt

rm -f instance-shutdown.txt
rm -f jumpcloud-agent.txt

echo "./userdata.txt created"