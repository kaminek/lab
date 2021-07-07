#!/bin/bash
set -e

if [ $# -ne 5 ]; then
    echo "usage: $0 VPC_ID VNI VTEP_LOCAL_IP GW_MAC_SUFFIX GW_IP"
    exit 1
fi

VPC_ID=$1
VNI=$2
VTEP_LOCAL_IP=$3
GW_MAC_SUFFIX=$4
GW_IP=$5

MAC_ADDR_ANYCAST_GW_PFX="44:33:33"
VRF_NAME="vrf${VPC_ID}"
BR_NAME="br${VNI}"
VXLAN_NAME="vx${VNI}"
GW_MAC="${MAC_ADDR_ANYCAST_GW_PFX}:${GW_MAC_SUFFIX}"

echo "creating bridge $BR_NAME within $VRF_NAME"
ip l add $BR_NAME type bridge
ip l s $BR_NAME address $GW_MAC
ip l set $BR_NAME master $VRF_NAME
ip addr add $GW_IP dev $BR_NAME 

echo "create vxlan $VXLAN_NAME"
ip l add $VXLAN_NAME type vxlan id $VNI dstport 4789 local $VTEP_LOCAL_IP nolearning
echo "plug $VXLAN_NAME to $BR_NAME"
ip l set $VXLAN_NAME master $BR_NAME

echo "set up $BR_NAME"
ip l s $BR_NAME up

echo "set up $VXLAN_NAME"
ip l s $VXLAN_NAME up
