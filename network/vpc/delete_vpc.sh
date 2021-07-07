#!/bin/bash

set -e

if [ $# -ne 1 ]; then
    echo "usage: $0 VPC_ID"
    exit 1
fi

VPC_ID=$1
VRF_NAME="vrf${VPC_ID}"

echo "deleting VPC id $VPC_ID"
echo "deleting vrf $VRF_NAME with table id $VPC_ID"
ip l del $VRF_NAME

