#!/bin/bash
vpnPort=1194

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#The following lines are for the VPN
iptables -A INPUT -p tcp --dport $vpnPort -j ACCEPT
iptables -A OUTPUT -p tcp --sport $vpnPort -j ACCEPT
iptables -A INPUT -p udp --dport $vpnPort -j ACCEPT
iptables -A OUTPUT -p udp --sport $vpnPort -j ACCEPT


iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

#DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
#iptables -A INPUT -p udp --sport 53 -j ACCEPT

#SSH
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT


iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

sleep 5 && iptables -F
