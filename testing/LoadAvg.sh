#!/usr/bin/ksh
# Examine system load and take an action when the load is at a certain level.

FPATH=/usr/local/bin/bcvscripts/lib

autoload Time_Counter
MANUAL_MONITOR=YES
REF_LOAD=5
print Reference Load is: ${REF_LOAD}

#SYS_LOAD=$(uptime | cut -d":" -f4 | cut -d"," -f1 | sed "s/\.//" )
SYS_LOAD=20

LOAD_VAR=bad
until [ ${LOAD_VAR} = "good" ]
do
	if (( ${SYS_LOAD} > ${REF_LOAD} ))
	then
		print Current system load is: ${SYS_LOAD}
		print Load High
		Time_Counter 2
		SYS_LOAD=$(( SYS_LOAD - 1 ))
	else
		print "#"
		print Load LOW
		LOAD_VAR=good
	fi
done
