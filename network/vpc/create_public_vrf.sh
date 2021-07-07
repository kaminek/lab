##!/bin/bash


ip l add vrf-pub type vrf table 99
ip l s vrf-pub up

ip l add lo-gw type dummy
ip l s lo-gw up

ip l s lo-gw master vrf-pub
ip addr add 169.254.254.254/32 dev lo-gw

exit 0
