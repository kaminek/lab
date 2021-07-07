##!/bin/bash

set -https://github.com/torvalds/linux.gite


# VM ID 010203
# where 01 is the host ID
# 02 is the network ID
# 03 is the VM ID in that network ID

VPC_ID=1001
VPC_PFX="10.0"
VTEP_LOCAL_IP=172.16.0.10

# Host 1
./create_vpc.sh 1001 

./create_vm.sh 010101 01:01:01 10.0.1.1/24 10.0.1.254
./create_vm.sh 010102 01:01:02 10.0.1.2/24 10.0.1.254
./create_vm.sh 010301 01:03:01 10.0.3.1/24 10.0.3.254

./create_l2vni_with_anycast_gw.sh 1001 1 172.16.0.10 00:01:01 10.0.1.254/24
./create_l2vni_with_anycast_gw.sh 1001 2 172.16.0.10 00:01:02 10.0.2.254/24
./create_l2vni_with_anycast_gw.sh 1001 3 172.16.0.10 00:01:03 10.0.3.254/24
./create_l2vni_with_anycast_gw.sh 1001 4 172.16.0.10 00:01:04 10.0.4.254/24

./plug_vm_l2vni.sh 010101 1
./plug_vm_l2vni.sh 010102 1
./plug_vm_l2vni.sh 010301 3

##### delete setup

./delete_vm.sh 010101
./delete_vm.sh 010102
./delete_vm.sh 010301

./delete_l2vni.sh 1001 1
./delete_l2vni.sh 1001 2
./delete_l2vni.sh 1001 3
./delete_l2vni.sh 1001 4

./delete_vpc.sh 1001
################



# Host 2
./create_vpc.sh 1001 

./create_vm.sh 020302 02:03:02 10.0.3.2/24 10.0.3.254
./create_vm.sh 020201 02:02:01 10.0.2.1/24 10.0.2.254
./create_vm.sh 020103 02:01:03 10.0.1.3/24 10.0.1.254

./create_l2vni_with_anycast_gw.sh 1001 1 172.16.0.20 00:01:01 10.0.1.254/24
./create_l2vni_with_anycast_gw.sh 1001 2 172.16.0.20 00:01:02 10.0.2.254/24
./create_l2vni_with_anycast_gw.sh 1001 3 172.16.0.20 00:01:03 10.0.3.254/24
./create_l2vni_with_anycast_gw.sh 1001 4 172.16.0.20 00:01:04 10.0.4.254/24

./plug_vm_l2vni.sh 020302 3
./plug_vm_l2vni.sh 020201 2
./plug_vm_l2vni.sh 020103 1


##### delete setup

./delete_vm.sh 020302
./delete_vm.sh 020201
./delete_vm.sh 020103

./delete_l2vni.sh 1001 1
./delete_l2vni.sh 1001 2
./delete_l2vni.sh 1001 3
./delete_l2vni.sh 1001 4

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

##### delete setup

./delete_vm.sh 030104
./delete_vm.sh 030202
./delete_vm.sh 030303
./delete_vm.sh 030401


./delete_l2vni.sh 1001 1
./delete_l2vni.sh 1001 2
./delete_l2vni.sh 1001 3
./delete_l2vni.sh 1001 4

./delete_vpc.sh 1001
################

