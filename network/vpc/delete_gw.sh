##!/bin/bash

# delete gw

source ./helpers.sh

if [ $# -ne 2 ]; then
    echo "usage: $0 VPC_ID GW_PUB_IP"
    exit 1
fi


VPC_ID=$1
GW_PUB_IP=$2

VRF_ID="100${VPC_ID}"
GW_IFNAME="gw$VRF_ID"
GW_TAP_IFNAME="tap-$GW_IFNAME"
VRF_IFNAME="vrf${VRF_ID}"
VRF_PUB_IFNAME="vrf-pub"

echo "remove gw ip addresse via the $VRF_IFNAME"
ip route del vrf vrf-pub ${GW_PUB_IP}/32 dev $VRF_IFNAME

ip l del $GW_IFNAME
ip route del vrf $VRF_IFNAME default via 169.254.254.254
ip route del vrf $VRF_IFNAME 169.254.254.254

iptables -t nat -D POSTROUTING -o $GW_IFNAME -j MASQUERADE

delete_vpc $VRF_ID 
delete_l3vni $VRF_ID

exit 0
