#!/usr/bin/ksh

## For testing FIFO pipe communications between scripts
## This file is for reading messages from the FIFO pipe.

SERVER=$1

while true
do
read NEW_MESSAGE < /usr/local/bin/bcvscripts/testing/${SERVER}_FIFO
print "New message received: ${NEW_MESSAGE}."
done
