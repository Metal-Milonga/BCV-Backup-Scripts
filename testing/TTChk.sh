#!/usr/bin/ksh

SERVER=$1
BINDIR="/usr/local/bin/bcvscripts/testing"
CFGDIR="/usr/local/bin/bcvscripts/testing"
CFGFILE="${CFGDIR}/time.cfg"
MANUAL_MONITOR=YES

SPLIT_TIME=$(grep ${SERVER}-STime ${CFGFILE}  | cut -d":" -f2)
print SPLIT_TIME is: ${SPLIT_TIME}
CURRENT_TIME=$(date +%H%M%S)
print CURRENT_TIME is: ${CURRENT_TIME}
DIFF_TIME=$(( ${SPLIT_TIME} - ${CURRENT_TIME} ))
print DIFF_TIME is: ${DIFF_TIME}
print "#"

DO_THE_LOOP(){
STOP_LOOP=1
until (( ${STOP_LOOP} == 0 ))
do
	print STOP_LOOP is: ${STOP_LOOP}
	CURRENT_TIME=$(date +%H%M%S)
	print CURRENT_TIME is: ${CURRENT_TIME}
	print SPLIT_TIME is: ${SPLIT_TIME}
	if (( ${CURRENT_TIME} > ${SPLIT_TIME} ))
	then
		print It\'s Time to Split.
		STOP_LOOP=0
		print "#"
	else
		print Don\'t Split Yet.
		DIFF_TIME=$(( ${SPLIT_TIME} - ${CURRENT_TIME} ))
		print DIFF_TIME is: ${DIFF_TIME}
		${BINDIR}/Time_Counter 60
		print; print "#"
	fi
done
}
#DO_THE_LOOP

print I\'m Done.
