#!/bin/bash
if [ $# -ne 2 ]; then
    echo "usage: $0 VPC_ID VNI "
    exit 1
fi

VPC_ID=$1
VNI=$2

VRF_NAME="vrf${VPC_ID}"
BR_NAME="br${VNI}"
VXLAN_NAME="vx${VNI}"

echo "deleting vxlan $VXLAN_NAME"
ip l del $VXLAN_NAME

echo "deleting bridge $BR_NAME inside $VRF_NAME"
ip l del $BR_NAME
