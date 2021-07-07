##!/bin/bash

# Host 5

source ./helpers.sh

if [ $# -ne 3 ]; then
    echo "usage: $0 ACTION LO_IFACE_NAME VPC_ID"
    exit 1
fi


ACTION=$1
LO_NAME=$2
VPC_ID=$3

VTEP_LOCAL_IP=$(ip -br a sh dev $LO_NAME | awk '{ print $3}' | cut -d / -f 1)


configure_host5() {

    local vrf_id="100${VPC_ID}"
    local vpc_addr_pfx="10.${VPC_ID}"

    create_vpc ${vrf_id} 
    create_l3vni "${vrf_id}" "${VTEP_LOCAL_IP}"

}

tear_down_host5() {

    local vrf_id="100${VPC_ID}"

    delete_vpc "${vrf_id}"
    delete_l3vni "${vrf_id}"
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





