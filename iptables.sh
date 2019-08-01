#!/bin/bash

# Empty any existing rule
iptables -F
iptables -t nat -F
iptables -t mangle -F

# Remove personnal chains
iptables -X
iptables -t nat -X
iptables -t mangle -X

# connections from outside
iptables -I FORWARD -o virbr0 -d  192.168.122.254 -j ACCEPT
iptables -t nat -I PREROUTING -p tcp --dport 17776 -j DNAT --to 192.168.122.254:17776
# Masquerade local subnet
iptables -I FORWARD -o virbr0 -d  192.168.122.254 -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -j MASQUERADE
iptables -A FORWARD -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i virbr0 -o eth0 -j ACCEPT
iptables -A FORWARD -i virbr0 -o lo -j ACCEPT

#iptables -t nat -A PREROUTING -p tcp --dport 2222 -j DNAT --to-destination 192.168.122.254:22
#iptables -t nat -A POSTROUTING -p tcp --dport 22 -d 192.168.122.254 -j SNAT --to 192.168.122.1
iptables -t nat -A PREROUTING -p TCP --dport 2222 -j DNAT --to-destination 192.168.122.254:22
iptables -I FORWARD -m state -d 192.168.122.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT
