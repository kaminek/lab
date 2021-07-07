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

configure_host3() {

    create_public_vrf

    create_vm_pub 0301 "192.168.3.1"
    create_vm_pub 0302 "192.168.3.2"

}

tear_down_host3()
{

    delete_vm_pub 0301
    delete_vm_pub 0302
}

case $ACTION in
    "create")
        configure_host3;;
    "delete")
        tear_down_host3;;
    "*")
        echo -n "unknown command";;
esac

exit 0




