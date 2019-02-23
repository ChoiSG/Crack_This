#!/bin/sh

# Reference
# https://www.digitalocean.com/community/tutorials/iptables-essentials-common-firewall-rules-and-commands

# Firewall rule for Elastic server 
# Includes SSH, HTTP, HTTPS, DNS, Elasticsearch (9200)
# Think about this 
# sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# As network traffic generally needs to be two-way—incoming and outgoing—to work properly, it is typical to create a firewall rule that allows established and related incoming traffic, so that the server will allow return traffic to outgoing connections initiated by the server itself. This command will allow that:

# Think about -i tun0   // VPN related firewall?? 

# Drop IPv6 stuffs
ip6tables -F
ip6tables -P INPUT DROP 
ip6tables -P OUTPUT DROP
ip6tables -A INPUT -j DROP
ip6tables -A OUTPUT -j DROP

# Flush everything before beginning

iptables -F 
iptables -X 

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# VPN SERVER WHITELIST DEBUG 
#iptables -A INPUT -p tcp -s 10.80.100.6 -j ACCEPT
#iptables -A OUTPUT -p tcp -d 10.80.100.6 -j ACCEPT

# SSH 
# Allowing 3 connections in 300 seconds, then an the ip for 300 seconds 
iptables -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --set --name DEFAULT --rsource 
iptables -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 300 --hitcount 3 --name DEFAULT --rsource -j DROP 
iptables -A INPUT -p tcp --dport 22 -j ACCEPT 

# OUTBound SSH, but do I need this for a server? 
#iptables -A OUTPUT -p tcp --sport 22 -m state --state NEW,ESTABLISHED,REL -j ACCEPT



# HTTP & HTTPS 
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sports 80,443 -m state --state ESTABLISHED,REL -j ACCEPT


# ICMP 
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT 

# DNS 
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT # Only for DEBUG
#iptables -A OUTPUT -p udp --dport 53 -d 10.0.0.0/24 -j ACCEPT # Accept DNS only from 10.0.0.0/24 network 

# DATABASE
#iptables -A INPUT -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT


# UNCOMMENT AFTER TALKING TO THE MAILMAN
# SMTP, IMAP, POP3 
#iptables -A INPUT -p tcp -m multiport --dports 25,110,143 -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -p tcp -m multiport --sports 25,110,143 -m state --state ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp --dport 9200:9300 -j ACCEPT


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

