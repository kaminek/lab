#!/bin/bash

set -e

MAC_ADDR_VENDOR_PFX="aa:bb:cc"
# ceate_vm MAC_ADDR_SUFFIX VMID 

if [ $# -ne 4 ]; then
    echo "usage: $0 VMID MAC_ADDR_SUFFIX IP_ADDR GW_IP"
    exit 1
fi

VMID=$1
MAC_ADDR_SUFFIX=$2
IP_ADDR=$3
GW_IP=$4

NETNS_NAME="vm${VMID}"
VM_TAP="tap${VMID}"
MAC_ADDR="${MAC_ADDR_VENDOR_PFX}:${MAC_ADDR_SUFFIX}"

echo "creating VM wiht id $VMID"
echo "creating netns $NETNS_NAME"
ip netns add $NETNS_NAME 

echo "creating veth peers with tap $VM_TAP"
ip link add veth0 type veth peer name $VM_TAP 

echo "setup up ifaces $VM_TAP and VM internal veth0"
ip l s $VM_TAP up

echo "put vm interface in VM (netns)"
ip l set veth0 netns $NETNS_NAME
ip netns exec $NETNS_NAME ip l s veth0 address $MAC_ADDR
ip netns exec $NETNS_NAME ip l s veth0 up
ip netns exec $NETNS_NAME ip addr add $IP_ADDR dev veth0
ip netns exec $NETNS_NAME ip r add default via $GW_IP dev veth0

