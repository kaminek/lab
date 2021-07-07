##!/bin/bash

# create gw

source ./helpers.sh

if [ $# -ne 2 ]; then
    echo "usage: $0 VPC_ID GW_PUB_IP"
    exit 1
fi


VPC_ID=$1
GW_PUB_IP=$2


VRF_ID="100${VPC_ID}"
GW_IFNAME="gw$VRF_ID"
GW_PEER_IFNAME="peer-$GW_IFNAME"
VRF_IFNAME="vrf${VRF_ID}"
VRF_PUB_IFNAME="vrf-pub"

VTEP_LOCAL_IP=$(ip -br a sh dev eth1 | awk '{ print $3}' | cut -d / -f 1)

create_vpc $VRF_ID 
create_l3vni_gw $VRF_ID $VTEP_LOCAL_IP

ip l add $GW_IFNAME type veth peer name $GW_PEER_IFNAME 

ip l s $GW_IFNAME master $VRF_IFNAME
ip l s $GW_IFNAME up 

ip l s $GW_PEER_IFNAME master $VRF_PUB_IFNAME
ip l s $GW_PEER_IFNAME up 
ip addr add 169.254.254.254/32 dev $GW_PEER_IFNAME

ip addr add ${GW_PUB_IP}/32 dev ${GW_IFNAME}

echo "leak gw ip addresse via the $VRF_IFNAME"
ip route add vrf vrf-pub ${GW_PUB_IP}/32 dev $GW_PEER_IFNAME

ip route add vrf $VRF_IFNAME 169.254.254.254 dev $GW_IFNAME
ip route add vrf $VRF_IFNAME default via 169.254.254.254

iptables -t nat -A POSTROUTING -o $GW_IFNAME -j MASQUERADE
exit 0
