#!/bin/bash

export HOME_DIR="/home/vagrant"

display_usage() {
        echo -e "\nUsage:\n$0 HOME_DIR VAGRANT_PUBLIC_IP CRC_IP \n"
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# if less than one argument supplied, display usage
if [  $# -le 2 ]
then
    display_usage
    exit 1
fi

HOME_DIR=$1
SERVER_IP=$2
CRC_IP=$3

# get deps
dnf -y install haproxy policycoreutils-python-utils firewalld

#configure firewalld
systemctl enable --now firewalld
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
systemctl restart firewalld
semanage port -a -t http_port_t -p tcp 6443

cat << EOF > /etc/haproxy/haproxy.cfg
global
debug

defaults
log global
mode http
timeout connect 0
timeout client 0
timeout server 0

frontend apps
bind $SERVER_IP:80
bind $SERVER_IP:443
option tcplog
mode tcp
default_backend apps

backend apps
mode tcp
balance roundrobin
option ssl-hello-chk
server webserver1 $CRC_IP check

frontend api
bind $SERVER_IP:6443
option tcplog
mode tcp
default_backend api

backend api
mode tcp
balance roundrobin
option ssl-hello-chk
server webserver1 $CRC_IP:6443 check
EOF

systemctl stop haproxy || :
systemctl enable haproxy || :
systemctl start haproxy

cat << EOF > $HOME_DIR/00-use-dnsmasq.conf
[main]
dns=dnsmasq
EOF

cat << EOF > $HOME_DIR/01-crc.conf
address=/apps-crc.testing/$SERVER_IP
address=/api.crc.testing/$SERVER_IP
EOF

#sudo mv /tmp/00-use-dnsmasq.conf /etc/NetworkManager/conf.d/00-use-dnsmasq.conf


