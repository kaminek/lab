#!/bin/bash

# delete_vm VMID 

if [ $# -ne 1 ]; then
    echo "usage: $0 VMID"
    exit 1
fi

VMID=$1

NETNS_NAME="vm${VMID}"
VM_TAP="tap${VMID}"

echo "deleting VM with id $VMID"

echo "deleting netns $NETNS_NAME"
ip netns del $NETNS_NAME 

# deleted by the peer device veth0
# echo "deleting VM tap $VM_TAP"
# ip l del $VM_TAP 
