#!/bin/bash
set -e

if [ $# -ne 2 ]; then
    echo "usage: $0 VM_ID VNI"
    exit 1
fi

VM_ID=$1
VNI=$2

TAP_NAME="tap${VM_ID}"
BR_NAME="br${VNI}"

echo "pluggging $TAP_NAME to bridge $BR_NAME"
ip l s $TAP_NAME master $BR_NAME

