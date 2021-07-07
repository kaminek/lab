##!/bin/bash

## Host 2 config

source ./helpers.sh

if [ $# -ne 3 ]; then
    echo "usage: $0 ACTION LO_IFACE_NAME VPC_ID"
    exit 1
fi


ACTION=$1
LO_NAME=$2
VPC_ID=$3

VTEP_LOCAL_IP=$(ip -br a sh dev $LO_NAME | awk '{ print $3}' | cut -d / -f 1)


configure_host2() {

    local vrf_id="100${VPC_ID}"
    local vpc_addr_pfx="10.${VPC_ID}"

    # enable fwd
    echo 1 > /proc/sys/net/ipv4/ip_forward


    if [ $VPC_ID -eq 3 ]; then
        create_peering
        exit 0
    fi

    create_vpc ${vrf_id} 
    create_l3vni "${vrf_id}" "${VTEP_LOCAL_IP}"

    if [ $VPC_ID -eq 1 ]; then
        local network2_id=2
        local vni2="${VPC_ID}${network2_id}"
        local network3_id=3
        local vni3="${VPC_ID}${network3_id}"

        create_vm 122 "${VPC_ID}2:02:02" "${vpc_addr_pfx}.${network2_id}.2/24" "${vpc_addr_pfx}.${network2_id}.254"
        create_vm 131 "${VPC_ID}2:03:01" "${vpc_addr_pfx}.${network3_id}.1/24" "${vpc_addr_pfx}.${network3_id}.254"

        create_l2vni_with_anycast_gw "${vrf_id}" "${vni2}" "${VTEP_LOCAL_IP}" "00:01:0${network2_id}" "${vpc_addr_pfx}.${network2_id}.254/24"
        create_l2vni_with_anycast_gw "${vrf_id}" "${vni3}" "${VTEP_LOCAL_IP}" "00:01:0${network3_id}" "${vpc_addr_pfx}.${network3_id}.254/24"

        plug_vm_l2vni 122 "${vni2}"
        plug_vm_l2vni 131 "${vni3}"

    elif [ $VPC_ID -eq 2 ]; then
        local network2_id=2
        local vni2="${VPC_ID}${network2_id}"

        create_vm 221 "${VPC_ID}2:02:01" "${vpc_addr_pfx}.${network2_id}.1/24" "${vpc_addr_pfx}.${network2_id}.254"

        create_l2vni_with_anycast_gw "${vrf_id}" "${vni2}" "${VTEP_LOCAL_IP}" "00:02:0${network2_id}" "${vpc_addr_pfx}.${network2_id}.254/24"

        plug_vm_l2vni 221 "${vni2}"
    fi

}

tear_down_host2() {

    local vrf_id="100${VPC_ID}"

    if [ $VPC_ID -eq 3 ]; then
        delete_peering
        exit 0
    fi

    if [ $VPC_ID -eq 1 ]; then
        local network2_id=2
        local vni2="${VPC_ID}${network2_id}"
        local network3_id=3
        local vni3="${VPC_ID}${network3_id}"

        delete_vm 122 
        delete_vm 131 

        delete_l2vni "${vrf_id}" "${vni2}" 
        delete_l2vni "${vrf_id}" "${vni3}" 

    elif [ $VPC_ID -eq 2 ]; then
        local network2_id=2
        local vni2="${VPC_ID}${network2_id}"

        delete_vm 221 
        delete_l2vni "${vrf_id}" "${vni2}" 
    fi

    delete_vpc "${vrf_id}"
    delete_l3vni "${vrf_id}"
}

case $ACTION in
    "create")
        configure_host2;;
    "delete")
        tear_down_host2;;
    "*")
        echo -n "unknown command";;
esac

exit 0



