##!/bin/bash

## Host 1 PUBLIC

source ./helpers.sh

if [ $# -ne 1 ]; then
    echo "usage: $0 ACTION"
    exit 1
fi


ACTION=$1
LO_GW_IFNAME="lo-gw"
VRF_ID=99

configure_host1() {

    create_public_vrf

    create_vm_pub 0101 "192.168.1.1"
    create_vm_pub 0102 "192.168.1.2"

}

tear_down_host1()
{

    delete_public_vrf

    delete_vm_pub 0101
    delete_vm_pub 0102
}

case $ACTION in
    "create")
        configure_host1;;
    "delete")
        tear_down_host1;;
    "*")
        echo -n "unknown command";;
esac

exit 0




