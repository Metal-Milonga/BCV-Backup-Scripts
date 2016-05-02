#!/usr/bin/ksh

GTIME="$1"
BTIME="$2"

print GTIME is: ${GTIME}
print BTIME is: ${BTIME}

while [ ${BTIME} -lt ${GTIME} ]
do
	sleep 30
	print $(date +%H%M%S)
	BTIME=$(date +%H%M%S)
done
