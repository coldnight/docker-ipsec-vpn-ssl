#!/bin/bash

set -e

DOMAIN_FN=$(echo $DOMAIN_NAME | sed -e 's/\./_/g')

SUBNET="172.16.0.0/16"

cat <<EOF > /etc/ipsec.conf
config setup
    uniqueids=never

conn %default
    keyexchange=ikev1
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    rekey=no
    keyingtries=1
    leftid=@${DOMAIN_NAME}
    leftsubnet=0.0.0.0/0
    leftauth=psk
    leftfirewall=yes
    right=%any
    rightdns=8.8.8.8,8.8.4.4
    rightsourceip=${SUBNET}
    rightauth=psk
    dpdaction=clear
    dpddelay=300s
    dpdtimeout=1h
    auto=add
    compress=yes

conn IPSec-IKEv2
    keyexchange=ikev2
    leftauth=pubkey
    leftcert=${DOMAIN_FN}.crt
    leftsendcert=always
    rightauth=eap-mschapv2
    rightsendcert=never
    eap_identity=%identity

conn CiscoIPSec
    aggressive=yes
    ike=aes256-sha1-modp1024!
    esp=aes256-sha1!
    type=tunnel
    xauth=server
    rightauth2=xauth-eap

conn android_xauth_psk
    left=%defaultroute
    rightauth2=xauth
EOF

cat <<EOF > /etc/ipsec.secrets
: PSK '${VPN_PSK}'
: RSA v_linuxzen_com.key
EOF

if [[ -e /etc/ipsec-xauth.secrets ]]
then
    cat /etc/ipsec-xauth.secrets >> /etc/ipsec.secrets
fi
iptables -I POSTROUTING 1 -s $SUBNET -j MASQUERADE -t nat
iptables -I FORWARD -m conntrack --ctstate SNAT -j ACCEPT
iptables -I FORWARD -m conntrack -s $SUBNET --ctstate NEW,RELATED,ESTABLISHED -j ACCEPT

exec ipsec start --nofork
