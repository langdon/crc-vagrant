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

sudo ./configure-remote-priv.sh $SERVER_IP $CRC_IP

#create the host dns files
cat << EOF > $HOME/00-use-dnsmasq.conf
[main]
dns=dnsmasq
EOF

cat << EOF > $HOME/01-crc.conf
address=/apps-crc.testing/$SERVER_IP
address=/api.crc.testing/$SERVER_IP
EOF

echo "On your host machine, you need to copy $HOME/00-use-dnsmasq.conf to /etc/NetworkManager/conf.d/ and "
echo "$HOME/01-crc to /etc/NetworkManager/dnsmasq.d/ and then sudo systemctl reload NetworkManager."


