#!/bin/sh
# tsig-keygen -a HMAC-SHA512 keyname >> keyfile

# example.net
ZONE=""
# example.net. / addr.example.net.
DOMAIN=""
# /PATH/TO/KEY/FILE
TSIG=""
# ns1.example.net, 123.45.67.89
NS=""


if [ -z "$ZONE" ] || [ -z "$DOMAIN" ] || [ -z "$TSIG" ] || [ -z "$NS" ]; then
	echo "NODATA"
	exit 1
fi

read -p "Get RR (G) / Add (A) / Update[Delete and Add] (U)/ Delete (D) ?:" WHAT
case $WHAT in
	G | g)
		read -p "Enter Type:" TYPE
		dig $DOMAIN $TYPE +short
		exit 0
	;;
	A | a)
		read -p "Enter TTL:" TTL
		read -p "Enter Type:" TYPE
		read -p "Enter RR:" RR
		if [ -z "$TTL" ] || [ -z "$TYPE" ] || [ -z "$RR" ]; then
			echo "NODATA"
			exit 1
		fi
		nsupdate -v -k "$TSIG" << EOF
server $NS
zone $ZONE
update add $DOMAIN $TTL $TYPE $RR
send
EOF
		exit 0
	;;
	D | d)
		read -p "Enter TTL:" TTL
		read -p "Enter Type:" TYPE
		read -p "Enter RR:" RR
		if [ -z "$TTL" ] || [ -z "$TYPE" ] || [ -z "$RR" ]; then
			echo "NODATA"
			exit 1
		fi
		nsupdate -v -k "$TSIG" << EOF
server $NS
zone $ZONE
update delete $DOMAIN $TTL $TYPE $RR
send
EOF
	exit 0
	;;

	U | u)
		read -p "Enter TTL:" TTL
		read -p "Enter Type:" TYPE
		read -p "Enter RR To Delete:" RR
		read -p "Enter RR To Update:" RRADD
		if [ -z "$TTL" ] || [ -z "$TYPE" ] || [ -z "$RR" ] || [ -z "$RRADD" ]; then
			echo "NODATA"
			exit 1
		fi
		nsupdate -v -k "$TSIG" << EOF
server $NS
zone $ZONE
update delete $DOMAIN $TTL $TYPE $RR
update add $DOMAIN $TTL $TYPE $RRADD
send
EOF
		exit 0
	;;

	*)
		echo "Error Exit..."
		exit 1
	;;
esac
exit 0
