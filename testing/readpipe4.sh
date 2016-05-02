#!/usr/bin/ksh

## For testing FIFO pipe communications between scripts
## This file is for reading messages from the FIFO pipe.

read VAR_1 VAR_2 < /usr/local/bin/bcvscripts/testing/FIFO

print ${VAR_1} ${VAR_2}

#print VAR_1 is: ${VAR_1}
#print VAR_2 is: ${VAR_2}

