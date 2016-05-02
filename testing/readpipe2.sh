#!/usr/bin/ksh

## For testing FIFO pipe communications between scripts
## This file is for reading messages from the FIFO pipe.

while true
do
read NEW_MESSAGE < /usr/local/bin/bcvscripts/testing/FIFO
print "New message received: ${NEW_MESSAGE}."
done
