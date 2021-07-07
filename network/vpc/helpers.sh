#!/bin/bash

###############################################################################################
create_l3vni () {
    if [ $# -ne 2 ]; then
        echo "usage: $0 VPC_ID VTEP_UNDERLAY_LOCAL_IP"
        exit 1
    fi

    sleep 2

    local VPC_ID=$1
    local VTEP_LOCAL_IP=$2

    local ROUTER_ID=$(echo $VTEP_LOCAL_IP | cut -d . -f 4)
    local VRF_NAME="vrf${VPC_ID}"
    local BR_NAME="br${VPC_ID}"
    local VXLAN_NAME="vx${VPC_ID}"

    echo "creating bridge $BR_NAME within $VRF_NAME"
    ip l add $BR_NAME type bridge
    ip l set $BR_NAME master $VRF_NAME

    echo "set up $BR_NAME"
    ip l s $BR_NAME up

    ip l sh $BR_NAME

    echo "create vxlan $VXLAN_NAME"
    ip l add $VXLAN_NAME type vxlan id $VPC_ID dstport 4789 local $VTEP_LOCAL_IP nolearning

    echo "set up $VXLAN_NAME"
    ip l set $VXLAN_NAME up  

    echo "plug $VXLAN_NAME to $BR_NAME"
    ip l set $VXLAN_NAME master $BR_NAME

    ip -c l sh $BR_NAME

    # wait to ip config to settle
    sleep 2

    echo "remove rp_filter for $BR_NAME"
    echo 0 > "/proc/sys/net/ipv4/conf/${BR_NAME}/rp_filter"

    ip -c l sh $BR_NAME

    # wait to ip config to settle
    sleep 2


    cat << EOF | vtysh
conf t
vrf $VRF_NAME
vni $VPC_ID
exit-vrf
router bgp 65001 vrf $VRF_NAME 
address-family ipv4 unicast
redistribute connected
exit-address-family
address-family l2vpn evpn 
advertise ipv4 unicast 
rd 65001:$ROUTER_ID
exit-address-family
exit
EOF
}

###############################################################################################
create_l3vni_gw () {
    if [ $# -ne 2 ]; then
        echo "usage: $0 VPC_ID VTEP_UNDERLAY_LOCAL_IP"
        exit 1
    fi

    sleep 2

    local VPC_ID=$1
    local VTEP_LOCAL_IP=$2

    local ROUTER_ID=$(echo $VTEP_LOCAL_IP | cut -d . -f 4)
    local VRF_NAME="vrf${VPC_ID}"
    local BR_NAME="br${VPC_ID}"
    local VXLAN_NAME="vx${VPC_ID}"

    echo "creating bridge $BR_NAME within $VRF_NAME"
    ip l add $BR_NAME type bridge
    ip l set $BR_NAME master $VRF_NAME

    echo "set up $BR_NAME"
    ip l s $BR_NAME up

    ip l sh $BR_NAME

    echo "create vxlan $VXLAN_NAME"
    ip l add $VXLAN_NAME type vxlan id $VPC_ID dstport 4789 local $VTEP_LOCAL_IP nolearning

    echo "set up $VXLAN_NAME"
    ip l set $VXLAN_NAME up  

    echo "plug $VXLAN_NAME to $BR_NAME"
    ip l set $VXLAN_NAME master $BR_NAME

    ip -c l sh $BR_NAME

    # wait to ip config to settle
    sleep 2

    echo "remove rp_filter for $BR_NAME"
    echo 0 > "/proc/sys/net/ipv4/conf/${BR_NAME}/rp_filter"

    ip -c l sh $BR_NAME

    # wait to ip config to settle
    sleep 2


    cat << EOF | vtysh
conf t
vrf $VRF_NAME
vni $VPC_ID
exit-vrf
router bgp 65001 vrf $VRF_NAME 
address-family ipv4 unicast
redistribute kernel 
exit-address-family
address-family l2vpn evpn 
advertise ipv4 unicast 
rd 65001:$ROUTER_ID
exit-address-family
exit
EOF
}

###############################################################################################
delete_l3vni ()
{
    if [ $# -ne 1 ]; then
        echo "usage: $0 VRF_ID"
        exit 1
    fi

    local VPC_ID=$1

    local VRF_NAME="vrf${VPC_ID}"
    local BR_NAME="br${VPC_ID}"
    local VXLAN_NAME="vx${VPC_ID}"

    echo "deleting vxlan $VXLAN_NAME"
    ip l del $VXLAN_NAME

    echo "deleting bridge $BR_NAME inside $VRF_NAME"
    ip l del $BR_NAME


    cat << EOF | vtysh
    conf t
    no vrf $VRF_NAME
    no router bgp 65001 vrf $VRF_NAME 
EOF
    
}

###############################################################################################
create_l2vni()
{
    if [ $# -ne 3 ]; then
        echo "usage: $0 VPC_ID VNI VTEP_LOCAL_IP"
        exit 1
    fi

    local VPC_ID=$1
    local VNI=$2
    local VTEP_LOCAL_IP=$3

    local VRF_NAME="vrf${VPC_ID}"
    local BR_NAME="br${VNI}"
    local VXLAN_NAME="vx${VNI}"

    echo "creating bridge $BR_NAME within $VRF_NAME"
    ip l add $BR_NAME type bridge
    ip l set $BR_NAME master $VRF_NAME

    echo "create vxlan $VXLAN_NAME"
    ip l add $VXLAN_NAME type vxlan id $VNI dstport 4789 local $VTEP_LOCAL_IP nolearning
    echo "plug $VXLAN_NAME to $BR_NAME"
    ip l set $VXLAN_NAME master $BR_NAME

    echo "set up $BR_NAME"
    ip l s $BR_NAME up
    echo "set up $VXLAN_NAME"
    ip l s $VXLAN_NAME up
    
}

###############################################################################################
create_l2vni_with_anycast_gw ()
{
    if [ $# -ne 5 ]; then
        echo "usage: $0 VPC_ID VNI VTEP_LOCAL_IP GW_MAC_SUFFIX GW_IP"
        exit 1
    fi

    # wait to ip config to settle
    sleep 2

    local VPC_ID=$1
    local VNI=$2
    local VTEP_LOCAL_IP=$3
    local GW_MAC_SUFFIX=$4
    local GW_IP=$5

    local MAC_ADDR_ANYCAST_GW_PFX="44:33:33"
    local VRF_NAME="vrf${VPC_ID}"
    local BR_NAME="br${VNI}"
    local VXLAN_NAME="vx${VNI}"
    local GW_MAC="${MAC_ADDR_ANYCAST_GW_PFX}:${GW_MAC_SUFFIX}"

    echo "creating bridge $BR_NAME within $VRF_NAME"
    ip l add $BR_NAME type bridge
    ip l s $BR_NAME address $GW_MAC
    ip l set $BR_NAME master $VRF_NAME
    ip addr add $GW_IP dev $BR_NAME 

    echo "create vxlan $VXLAN_NAME"
    ip l add $VXLAN_NAME type vxlan id $VNI dstport 4789 local $VTEP_LOCAL_IP nolearning
    echo "plug $VXLAN_NAME to $BR_NAME"
    ip l set $VXLAN_NAME master $BR_NAME

    echo "set up $BR_NAME"
    ip l s $BR_NAME up

    echo "set up $VXLAN_NAME"
    ip l s $VXLAN_NAME up

    # wait to ip config to settle
    sleep 2

    echo "remove rp_filter for $BR_NAME"
    echo 0 > "/proc/sys/net/ipv4/conf/${BR_NAME}/rp_filter"
}

###############################################################################################
delete_l2vni ()
{
    if [ $# -ne 2 ]; then
        echo "usage: $0 VRF_ID VNI"
        exit 1
    fi

    local VPC_ID=$1
    local VNI=$2

    local VRF_NAME="vrf${VPC_ID}"
    local BR_NAME="br${VNI}"
    local VXLAN_NAME="vx${VNI}"

    echo "deleting vxlan $VXLAN_NAME"
    ip l del $VXLAN_NAME

    echo "deleting bridge $BR_NAME inside $VRF_NAME"
    ip l del $BR_NAME
}


create_public_vrf () {

    ip l add vrf-pub type vrf table 99
    ip l s vrf-pub up

    ip l s eth2 master vrf-pub

}

delete_public_vrf () {

    ip l del vrf-pub

}

###############################################################################################
create_vm_pub ()
{
    if [ $# -ne 2 ]; then
        echo "usage: create_vm_pub VMID IP_ADDR"
        exit 1
    fi

    local vm_id=$1
    local ip_addr=$2

    local netns_name="pub_vm${vm_id}"
    local vm_tap="pub_tap${vm_id}"

    echo "creating VM wiht id $vm_id"
    echo "creating netns $netns_name"
    ip netns add $netns_name 

    echo "creating veth peers with tap $vm_tap"
    ip link add veth0 type veth peer name $vm_tap 

    echo "setup up ifaces $vm_tap and VM internal veth0"
    ip l s $vm_tap up
    ip l s $vm_tap master vrf-pub
    ip addr add 169.254.254.254/32 dev $vm_tap

    echo "put vm interface in VM (netns)"
    ip l set veth0 netns $netns_name
    ip netns exec $netns_name ip l s veth0 up
    ip netns exec $netns_name ip addr add $ip_addr dev veth0
    ip netns exec $netns_name ip r add 169.254.254.254 dev veth0
    ip netns exec $netns_name ip r add default via 169.254.254.254 dev veth0

    echo "setup vm pub ip reachability"
    ip route add vrf vrf-pub ${ip_addr}/32 dev ${vm_tap}
}

###############################################################################################
delete_vm_pub ()
{
    
    if [ $# -ne 1 ]; then
        echo "usage: delete_vm VMID"
        exit 1
    fi

    local vm_id=$1

    local NETNS_NAME="pub_vm${vm_id}"
    local VM_TAP="pub_tap${vm_id}"

    echo "deleting public VM with id $vm_id"

    echo "deleting netns $NETNS_NAME"
    ip netns del $NETNS_NAME 

    echo "removing the vm route from vrf pub, should be auto"
    # ip 
}


###############################################################################################
create_vm ()
{
    if [ $# -ne 4 ]; then
        echo "usage: create_vm VMID MAC_ADDR_SUFFIX IP_ADDR GW_IP"
        exit 1
    fi

    local vm_id=$1
    local mac_addr_suffix=$2
    local ip_addr=$3
    local gw_ip=$4

    local mac_addr_vendor_pfx="aa:bb:0${vpc_id}"
    local netns_name="vm${vm_id}"
    local vm_tap="tap${vm_id}"
    local mac_addr="${mac_addr_vendor_pfx}:${mac_addr_suffix}"

    echo "creating VM wiht id $vm_id"
    echo "creating netns $netns_name"
    ip netns add $netns_name 

    echo "creating veth peers with tap $vm_tap"
    ip link add veth0 type veth peer name $vm_tap 

    echo "setup up ifaces $vm_tap and VM internal veth0"
    ip l s $vm_tap up

    echo "put vm interface in VM (netns)"
    ip l set veth0 netns $netns_name
    ip netns exec $netns_name ip l s veth0 address $mac_addr
    ip netns exec $netns_name ip l s veth0 up
    ip netns exec $netns_name ip addr add $ip_addr dev veth0
    ip netns exec $netns_name ip r add default via $gw_ip dev veth0
}

###############################################################################################
delete_vm ()
{
    
    if [ $# -ne 1 ]; then
        echo "usage: delete_vm VMID"
        exit 1
    fi

    local vm_id=$1

    local NETNS_NAME="vm${vm_id}"
    local VM_TAP="tap${vm_id}"

    echo "deleting VM with id $vm_id"

    echo "deleting netns $NETNS_NAME"
    ip netns del $NETNS_NAME 
    # peer device is auto deleted
}

###############################################################################################
create_vpc ()
{
    if [ $# -ne 1 ]; then
        echo "usage: $0 VPC_ID"
        exit 1
    fi

    local VPC_ID=$1
    local VRF_NAME="vrf${VPC_ID}"

    echo "creating VPC id $VPC_ID"
    echo "creating vrf $VRF_NAME with table id $VPC_ID"
    ip l add $VRF_NAME type vrf table ${VPC_ID}
    ip l s $VRF_NAME up
}

###############################################################################################
create_peering () {

    echo "leaking routes between VRFs"
    ip route add vrf vrf1001 10.2.0.0/16 dev vrf1002 
    ip route add vrf vrf1002 10.1.0.0/16 dev vrf1001 

}

###############################################################################################
delete_peering () {

    echo "delete leaking routes between VRFs"
    ip route del vrf vrf1001 10.2.0.0/16 dev vrf1002 
    ip route del vrf vrf1002 10.1.0.0/16 dev vrf1001 

}

###############################################################################################
delete_vpc ()
{
    if [ $# -ne 1 ]; then
        echo "usage: delete_vpc 0 VPC_ID"
        exit 1
    fi

    local VPC_ID=$1
    local VRF_NAME="vrf${VPC_ID}"

    echo "deleting VPC id $VPC_ID"
    echo "deleting vrf $VRF_NAME with table id $VPC_ID"
    ip l del $VRF_NAME
}

###############################################################################################
plug_vm_l2vni ()
{
    
    if [ $# -ne 2 ]; then
        echo "usage: $0 VM_ID VNI"
        exit 1
    fi

    local VM_ID=$1
    local VNI=$2

    local TAP_NAME="tap${VM_ID}"
    local BR_NAME="br${VNI}"

    echo "pluggging $TAP_NAME to bridge $BR_NAME"
    ip l s $TAP_NAME master $BR_NAME

}

###############################################################################################
configure_bgp_speaker ()
{
    if [ $# -ne 1 ]; then
        echo "usage: $0 HOSTNAME LO_IPADDR RR_IPADDR"
        exit 1
    fi

    local hostname=$1
    local lo_ipaddr=$2
    local rr_ipaddr=$3
    
    cat << EOF | vtysh
    hostname ${hostname}
    log syslog informational
    no ipv6 forwarding
    debug zebra events
    debug zebra rib
    debug zebra vxlan
    debug bgp updates in
    debug bgp updates out
    debug bgp zebra

    router bgp 65001
     bgp router-id ${lo_ipaddr}
     bgp log-neighbor-changes
     no bgp default ipv4-unicast
     neighbor fabric peer-group
     neighbor fabric remote-as 65001
     neighbor ${rr_ipaddr} peer-group fabric
     !
     address-family l2vpn evpn
      neighbor fabric activate
      advertise-all-vni
     exit-address-family
    !
    exit
EOF

}

###############################################################################################
configure_rr ()
{
    if [ $# -ne 1 ]; then
        echo "usage: $0 HOSTNAME LO_IPADDR PEER_GROUP_NETWORK"
        exit 1
    fi

    local hostname=$1
    local lo_ipaddr=$2
    local peer_group_ipaddr=$3
    
    cat << EOF | vtysh
    hostname ${hostname}
    log syslog informational
    no ip forwarding
    no ipv6 forwarding
    service integrated-vtysh-config
    !
    router bgp 65001
     bgp router-id ${lo_ipaddr}
     bgp log-neighbor-changes
     no bgp default ipv4-unicast
     neighbor fabric peer-group
     neighbor fabric remote-as 65001
     neighbor fabric update-source ${lo_ipaddr} 
     neighbor fabric capability extended-nexthop
     bgp listen range ${peer_group_ipaddr} peer-group fabric
     !
     address-family l2vpn evpn
      neighbor fabric activate
      neighbor fabric route-reflector-client
     exit-address-family
    exit
    !
EOF
    
}
###############################################################################################

###############################################################################################
