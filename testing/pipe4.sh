#!/usr/bin/ksh

## For testing FIFO pipe communications between scripts.
## This file is for sending messages to the FIFO pipe.

SERVER=${1}
VAR_1=${2}
VAR_2=${3}

#print "${VAR_1}, ${VAR_2}!" > /usr/local/bin/bcvscripts/testing/${SERVER}_FIFO
print "${VAR_1}, ${VAR_2}!" > /usr/local/bin/bcvscripts/testing/FIFO
