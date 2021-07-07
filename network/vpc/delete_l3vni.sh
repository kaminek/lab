#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 VPC_ID"
    exit 1
fi

VPC_ID=$1

VRF_NAME="vrf${VPC_ID}"
BR_NAME="br${VPC_ID}"
VXLAN_NAME="vx${VPC_ID}"

echo "deleting vxlan $VXLAN_NAME"
ip l del $VXLAN_NAME

echo "deleting bridge $BR_NAME inside $VRF_NAME"
ip l del $BR_NAME

cat << EOF | vtysh
conf t
no vrf $VRF_NAME
no router bgp 65001 vrf $VRF_NAME 
EOF
