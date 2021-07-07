#!/bin/bash
set -e

if [ $# -ne 2 ]; then
    echo "usage: $0 VPC_ID VTEP_UNDERLAY_LOCAL_IP"
    exit 1
fi

VPC_ID=$1
VTEP_LOCAL_IP=$2

VRF_NAME="vrf${VPC_ID}"
BR_NAME="br${VPC_ID}"
VXLAN_NAME="vx${VPC_ID}"

echo "creating bridge $BR_NAME within $VRF_NAME"
ip l add $BR_NAME type bridge
ip l set $BR_NAME master $VRF_NAME

echo "create vxlan $VXLAN_NAME"
ip l add $VXLAN_NAME type vxlan id $VPC_ID dstport 4789 local $VTEP_LOCAL_IP nolearning
echo "plug $VXLAN_NAME to $BR_NAME"
ip l set $VXLAN_NAME master $BR_NAME

echo "set up $BR_NAME"
ip l s $BR_NAME up

cat << EOF | vtysh
conf t
vrf $VRF_NAME
 vni $VPC_ID
 exit-vrf
router bgp 65001 vrf $VRF_NAME 
 address-family ipv4 unicast
  redistribute connected
 exit-address-family
 address-family l2vpn evpn 
  advertise ipv4 unicast 
 exit-address-family
 exit
EOF


echo "set up $VXLAN_NAME"
ip l s $VXLAN_NAME up
