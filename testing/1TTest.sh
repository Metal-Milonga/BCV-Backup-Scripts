#!/usr/bin/ksh

SERVER=$1
BINDIR="/usr/local/bin/bcvscripts/testing"
CFGDIR="/usr/local/bin/bcvscripts/testing"
TTCFGFILE=${CFGDIR}/time.cfg
	#server09-STime:080000
	#server16-STime:183300
MANUAL_MONITOR=NO
COUNT_TIME_9=900

Determine_Wait() {

#if (( ${DIFF_TIME} > 37000 ))
if (( ${DIFF_TIME} > 30000 ))
then
	print Don\'t Split Yet.
	#print "I would sleep for 3hrs (10800 sec)"
	COUNT_TIME=10800

#elif (( (${DIFF_TIME} >= 30000) && (${DIFF_TIME} <= 36999) ))
elif (( (${DIFF_TIME} >= 20000) && (${DIFF_TIME} <= 29999) ))
then
	print Don\'t Split Yet.
	#print "I would sleep for 2hrs (7200 sec)"
	COUNT_TIME=7200

#elif (( (${DIFF_TIME} >= 20000) && (${DIFF_TIME} <= 29999) ))
elif (( (${DIFF_TIME} >= 10000) && (${DIFF_TIME} <= 19999) ))
then
	print Don\'t Split Yet.
	#print "I would sleep for 1hr (3600 sec)"
	COUNT_TIME=3600

elif (( (${DIFF_TIME} >= 3000) && (${DIFF_TIME} <= 9999) ))
then
	print Don\'t Split Yet.
	#print "I would sleep for 30mins (1800 sec)"
	COUNT_TIME=1800

elif (( (${DIFF_TIME} >= 0) && (${DIFF_TIME} <= 2999) ))
then
	print Don\'t Split Yet.
	#print "I would sleep for 15mins  (${COUNT_TIME_9} sec)"
	COUNT_TIME=${COUNT_TIME_9}
fi

#print COUNT_TIME is set to: ${COUNT_TIME}
#print "#"
}

DO_THE_LOOP(){
STOP_LOOP=1
until (( ${STOP_LOOP} == 0 ))
do
	SPLIT_TIME=$(grep ${SERVER}-STime ${TTCFGFILE}  | cut -d":" -f2)
	print SPLIT_TIME is: ${SPLIT_TIME}

	CURRENT_TIME=$(date +%H%M%S)
	print CURRENT_TIME is: ${CURRENT_TIME}

	DIFF_TIME=$(( ${SPLIT_TIME} - ${CURRENT_TIME} ))
	print DIFF_TIME is: ${DIFF_TIME}
	print "#"

	Determine_Wait

	if (( ${CURRENT_TIME} > ${SPLIT_TIME} ))
	then
		print It\'s Time to Split.
		STOP_LOOP=0
		print "#"
	else
		${BINDIR}/Time_Counter ${COUNT_TIME}
		print; print "#"
	fi
done
}
DO_THE_LOOP

print I\'m Done.
