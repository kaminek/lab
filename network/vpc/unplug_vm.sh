#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "usage: $0 VM_ID"
    exit 1
fi

VM_ID=$1

TAP_NAME="tap${VM_ID}"

echo "unpluggging $TAP_NAME from bridge"
ip l s $TAP_NAME nomaster

