#!/bin/sh

# Firewall rule for Elastic server 
# Includes SSH, HTTP, HTTPS, DNS, Elasticsearch (9200)

# Drop IPv6 stuffs
ip6tables -F
ip6tables -P INPUT DROP 
ip6tables -P OUTPUT DROP
ip6tables -A INPUT -j DROP
ip6tables -A OUTPUT -j DROP

# Flush everything before beginning

iptables -F 
iptables -X 

# Loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT


iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


# ICMP 
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT 

# DNS 
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT # Only for DEBUG
#iptables -A OUTPUT -p udp --dport 53 -d 10.0.0.0/24 -j ACCEPT # Accept DNS only from 10.0.0.0/24 network 

# DHCP?
iptables -A INPUT -p udp --sport 67 --dport 68 -j ACCEPT

######## END OF FIREWALL ############

# Drop ALL OTHER THINGS 
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP


# DEBUG - UNcomment for SERVERS only  
#sleep 15

#iptables  -F
#iptables -F 
#iptables  -X
#iptables -X 

