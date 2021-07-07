#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 VPC_ID"
    exit 1
fi

VPC_ID=$1
VRF_NAME="vrf${VPC_ID}"

echo "creating VPC id $VPC_ID"
echo "creating vrf $VRF_NAME with table id $VPC_ID"
ip l add $VRF_NAME type vrf table ${VPC_ID}
ip l s $VRF_NAME up
