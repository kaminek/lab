##!/bin/bash

## Host 5 PUBLIC

source ./helpers.sh

if [ $# -ne 1 ]; then
    echo "usage: $0 ACTION"
    exit 1
fi


ACTION=$1
LO_GW_IFNAME="lo-gw"
VRF_ID=99

configure_host5() {

    create_public_vrf

    create_vm_pub 0501 "192.168.5.1"
    create_vm_pub 0502 "192.168.5.2"

}

tear_down_host5()
{
    delete_vm_pub 0501
    delete_vm_pub 0502
}

case $ACTION in
    "create")
        configure_host5;;
    "delete")
        tear_down_host5;;
    "*")
        echo -n "unknown command";;
esac

exit 0



