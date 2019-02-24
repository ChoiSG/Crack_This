#!/bin/bash
pkg install dns/bind913
echo "Adding zone to config and updating the listening IP"
printf 'zone "team8.cybertigers.club" {\n	type master;\n	file "/usr/local/etc/namedb/master/cybertigers.club\n	};' >> /usr/local/etc/namedb/named.conf
sed -i.bak 's/127.0.0.1;/10.3.8.1;/g' /usr/local/etc/namedb/named.conf
cat >/usr/local/etc/namedb/master/cybertigers.club << EOL
$TTL 86400
@	1D	IN	SOA	ns1.team8.cybertigers.club.	root.team8.cybertigers.club. (
								2
								3H
								15
								1w
								3h
								)

		IN	NS	ns1.team8.cybertigers.club.

ns1		IN	A	10.3.8.1
bonaparte	IN	A	10.3.8.2
ataturk		IN	A	10.3.8.3
EOL
echo 'named_enable="YES"' >> /etc/rc.conf
/usr/local/etc/rc.d/named start
