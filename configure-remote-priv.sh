#!/bin/bash

display_usage() {
        echo -e "\nUsage:\n$0 SERVER_IP CRC_IP \n"
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# if less than one argument supplied, display usage
if [  $# -le 1 ]
then
    display_usage
    exit 1
fi

SERVER_IP=$1
CRC_IP=$2

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
bind :80
bind :443
option tcplog
mode tcp
default_backend apps

backend apps
mode tcp
balance roundrobin
server webserver1 $CRC_IP

frontend api
bind :6443
option tcplog
mode tcp
default_backend api

backend api
mode tcp
balance roundrobin
server webserver1 $CRC_IP:6443
EOF

systemctl stop haproxy || :
systemctl enable haproxy || :
systemctl start haproxy


