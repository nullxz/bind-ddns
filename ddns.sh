#!/bin/sh
# tsig-keygen -a HMAC-SHA512 keyname >> keyfile
# 4 or 6
IPv="4"
# example.net
ZONE=""
# example.net. / addr.example.net.
DOMAIN=""
# /PATH/TO/KEY/FILE
TSIG=""
# ns1.example.net, 123.45.67.89
NS=""
# 60 = minute, 300 = 5minute, 3600 = 1hour
TTL="60"

case $IPv in
	4)
		RR=$(curl -4 -s https://api.cloudflare.com/cdn-cgi/trace | awk -F= '/ip=([0-9.]+)/ {print $2}')
		TYPE="A"
	;;
	6)
		RR=$(curl -6 -s https://api.cloudflare.com/cdn-cgi/trace | awk -F= '/ip=([0-9a-fA-F:]+)/ {print $2}')
		TYPE="AAAA"
	;;
	*)
		echo "ERROR: Allow Only IPv4 OR IPv6"
		exit 1
	;;
esac
if [ $RR = $(dig $DOMAIN +short) ]; then
	echo "IP NOT CHANGE"
	echo "Exit...."
	exit 0
else
	echo "Wait....."
fi;
echo $RR
nsupdate -v -k $TSIG << EOF
server $NS
zone $ZONE
update delete $DOMAIN $TYPE
update add $DOMAIN $TTL $TYPE $RR
send
EOF

exit 0
