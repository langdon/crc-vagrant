#!/bin/bash

#relies on configuration form setup-run-crc.sh

until [ `$HOME/bin/crc ip` ];
do
  echo "Waiting for crc to come up......"
  sleep 10s
done

# get some data about the machine
#don't need this anymore but the command might be useful
SERVER_IP=`hostname -I | awk ' { print $2 }'`
CRC_IP=`$HOME/bin/crc ip`
sudo ./configure-remote-priv.sh $HOME $SERVER_IP $CRC_IP

