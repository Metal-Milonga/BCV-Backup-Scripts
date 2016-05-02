#!/usr/bin/ksh

GOAL=$1
COUNT=0

until (( $COUNT >= $GOAL ))
do
	for T in '\' '|' '/' '-'
	do
		print "\t${T} \r\c"
		sleep 1 
		((COUNT+=1))
	done
done
