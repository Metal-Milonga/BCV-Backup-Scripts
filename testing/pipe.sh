#!/usr/bin/ksh

## For testing FIFO pipe communications between scripts.
## This file is for sending messages to the FIFO pipe.

MESSAGE1=${1}
MESSAGE2=${2}
MESSAGE3=${3}
MESSAGE4=${4}

##print ${MESSAGE} > /usr/local/bin/bcvscripts/testing/FIFO

for MESS in ${MESSAGE2} ${MESSAGE3} ${MESSAGE4}
do
	print working ${MESS}
	print "${MESSAGE1}, ${MESS}!" > /usr/local/bin/bcvscripts/testing/FIFO
	sleep 1
done
