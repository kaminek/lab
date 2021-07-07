##!/bin/bash

# get the helper functions
source ./helpers.sh


# VM ID 010203
# where 01 is the host ID
# 02 is the network ID
# 03 is the VM ID in that network ID

configure_host1() {
    if [ $# -ne 1 ]; then
        echo "usage: $0 VPC_ID"
        exit 1
    fi

    local vpc_id=$1

    local vrf_id="100${vpc_id}"
    local vpc_addr_pfx="10.${vpc_id}"

    create_vpc ${vrf_id} 
    create_l3vni "${vrf_id}" "${VTEP_LOCAL_IP}"

    if [ $vpc_id eq 1 ]; then
        local vni1="${vpc_id}1"
        create_vm 01010101 01:01:01 "${vpc_addr_pfx}.1.1/24" "${vpc_addr_pfx}.1.254"
        create_vm 01010102 01:01:02 "${vpc_addr_pfx}.1.2/24" "${vpc_addr_pfx}.1.254"

        create_l2vni_with_anycast_gw "${vrf_id}" "${vni1}" "${VTEP_LOCAL_IP}" 00:01:01 "${vpc_addr_pfx}.1.254/24"

        plug_vm_l2vni 010101 "${vni1}"
        plug_vm_l2vni 010102 "${vni1}"

    elif [ vpc_id eq 2 ]; then
        local vni1="${vpc_id}1"
    fi


}

tear_down_host1()
{
    if [ $# -ne 1 ]; then
        echo "usage: $0 VPC_ID"
        exit 1
    fi

    local vpc_id=$1

    local vrf_id="100${vpc_id}"
    local vni1="${vpc_id}1"

    delete_vm 010101 ${vpc_id}
    delete_vm 010102 ${vpc_id}

    delete_l2vni "${vrf_id}" "${vni1}" 

    delete_l3vni "${vrf_id}"
    delete_vpc "${vrf_id}"
}

if [ $# -ne 2 ]; then
    echo "usage: $0 ACTION LO_IFACE_NAME"
    exit 1
fi

ACTION=$1
LO_NAME=$2

HOSTNAME=$(echo $HOSTNAME)
VTEP_LOCAL_IP=$(ip -br a sh dev $LO_NAME | awk '{ print $3}' | cut -d / -f 1)

# Host 1
case $HOSTNAME in 
    "host1")
        case $ACTION in
            "create")
                configure_host1 1;;
            "delete")
                tear_down_host1 1;;
            "*")
                echo -n "unknown command";;
        esac
        ;;
    "host2")
        configure_host2 1;;
    "*")
        echo -n "unknown host";;
esac

exit 0


configure_host2() {
    if [ $# -ne 2 ]; then
        echo "usage: $0 VPC_ID VPC_IPADDR_PFX"
        exit 1
    fi

    local vpc_id=$1
    local vpc_ipaddr_pfx=$2

    local vrf_id="100${vpc_id}"

    create_vpc ${vrf_id} 

    create_vm.sh 020201 02:02:01 10.0.2.1/24 10.0.2.254
./create_vm.sh 020103 02:01:03 10.0.1.3/24 10.0.1.254

./create_l2vni_with_anycast_gw.sh 1001 1 172.16.0.20 00:01:01 10.0.1.254/24
./create_l2vni_with_anycast_gw.sh 1001 2 172.16.0.20 00:01:02 10.0.2.254/24
# ./create_l2vni_with_anycast_gw.sh 1001 3 172.16.0.20 00:01:03 10.0.3.254/24

# ./plug_vm_l2vni.sh 020302 3
./plug_vm_l2vni.sh 020201 2
./plug_vm_l2vni.sh 020103 1





./create_vm.sh 020201 02:02:01 10.0.2.1/24 10.0.2.254
    create_vm 020201 02:02:01 "${vpc_ipaddr_pfx}.2.1/24" "${vpc_ipaddr_pfx}.2.254"

    create_l2vni_with_anycast_gw "${vpc_id}" 10 "${VTEP_LOCAL_IP}" 00:01:01 "${vpc_ipaddr_pfx}.1.254/24"

    plug_vm_l2vni 010101 10
    plug_vm_l2vni 010102 10

    create_l3vni "${vpc_id}" "${VTEP_LOCAL_IP}"
}

################



# Host 2
./create_vpc.sh 1001 

# ./create_vm.sh 020302 02:03:02 10.0.3.2/24 10.0.3.254
./create_vm.sh 020201 02:02:01 10.0.2.1/24 10.0.2.254
./create_vm.sh 020103 02:01:03 10.0.1.3/24 10.0.1.254

./create_l2vni_with_anycast_gw.sh 1001 1 172.16.0.20 00:01:01 10.0.1.254/24
./create_l2vni_with_anycast_gw.sh 1001 2 172.16.0.20 00:01:02 10.0.2.254/24
# ./create_l2vni_with_anycast_gw.sh 1001 3 172.16.0.20 00:01:03 10.0.3.254/24

# ./plug_vm_l2vni.sh 020302 3
./plug_vm_l2vni.sh 020201 2
./plug_vm_l2vni.sh 020103 1

./create_l3vni.sh 1001 172.16.0.20

##### delete setup

./delete_vm.sh 020302
./delete_vm.sh 020201
./delete_vm.sh 020103

./delete_l2vni.sh 1001 1
./delete_l2vni.sh 1001 2
./delete_l2vni.sh 1001 3

./delete_l3vni.sh 1001
./delete_vpc.sh 1001
################





# Host 3
./create_vpc.sh 1001 

./create_vm.sh 030104 03:01:04 10.0.1.4/24 10.0.1.254
./create_vm.sh 030202 03:02:02 10.0.2.2/24 10.0.2.254
./create_vm.sh 030303 03:03:03 10.0.3.3/24 10.0.3.254
./create_vm.sh 030401 03:04:01 10.0.4.1/24 10.0.4.254

./create_l2vni_with_anycast_gw.sh 1001 1 172.16.0.30 00:01:01 10.0.1.254/24
./create_l2vni_with_anycast_gw.sh 1001 2 172.16.0.30 00:01:02 10.0.2.254/24
./create_l2vni_with_anycast_gw.sh 1001 3 172.16.0.30 00:01:03 10.0.3.254/24
./create_l2vni_with_anycast_gw.sh 1001 4 172.16.0.30 00:01:04 10.0.4.254/24

./plug_vm_l2vni.sh 030104 1
./plug_vm_l2vni.sh 030202 2
./plug_vm_l2vni.sh 030303 3
./plug_vm_l2vni.sh 030401 4

./create_l3vni.sh 1001 172.16.0.30

##### delete setup

./delete_vm.sh 030104
./delete_vm.sh 030202
./delete_vm.sh 030303
./delete_vm.sh 030401


./delete_l2vni.sh 1001 1
./delete_l2vni.sh 1001 2
./delete_l2vni.sh 1001 3
./delete_l2vni.sh 1001 4

./delete_l3vni.sh 1001
./delete_vpc.sh 1001
################

