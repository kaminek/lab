#!/bin/bash
set -e

if [ $# -ne 3 ]; then
    echo "usage: $0 VPC_ID VNI VTEP_LOCAL_IP"
    exit 1
fi

VPC_ID=$1
VNI=$2
VTEP_LOCAL_IP=$3

# TAP_NAME="tap${VMID}"
VRF_NAME="vrf${VPC_ID}"
BR_NAME="br${VNI}"
VXLAN_NAME="vx${VNI}"

echo "creating bridge $BR_NAME within $VRF_NAME"
ip l add $BR_NAME type bridge
ip l set $BR_NAME master $VRF_NAME

echo "create vxlan $VXLAN_NAME"
ip l add $VXLAN_NAME type vxlan id $VNI dstport 4789 local $VTEP_LOCAL_IP nolearning
echo "plug $VXLAN_NAME to $BR_NAME"
ip l set $VXLAN_NAME master $BR_NAME

echo "set up $BR_NAME"
ip l s $BR_NAME up
echo "set up $VXLAN_NAME"
ip l s $VXLAN_NAME up
