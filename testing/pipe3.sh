#!/usr/bin/ksh

## For testing FIFO pipe communications between scripts.
## This file is for sending messages to the FIFO pipe.

SERVER=${1}
GREETING=${2}
MESSAGE1=${3}
MESSAGE2=${4}
MESSAGE3=${5}

for MESS in ${MESSAGE1} ${MESSAGE2} ${MESSAGE3}
do
	print working ${MESS}
	print "${GREETING}, ${MESS}!" > /usr/local/bin/bcvscripts/testing/${SERVER}_FIFO
	sleep 1
done
