#!/usr/bin/ksh

SERVER=$1
BINDIR="/usr/local/bin/bcvscripts/testing"
CFGDIR="/usr/local/bin/bcvscripts/testing"
TTCFGFILE=${CFGDIR}/time.cfg
	#server09-STime:234500
	#server16-STime:234500
export MANUAL_MONITOR=YES
COUNT_TIME_9=900
COUNT_TIME_6=600
COUNT_TIME_3=300

Determine_Wait() {

####if (( ${DIFF_TIME} > 110000 )); then
####	print Don\'t Split Yet.
####	print "I would sleep for 11hrs (39600 sec)"
####	COUNT_TIME=39600
####
####elif (( (${DIFF_TIME} >= 100000) && (${DIFF_TIME} <= 109999) )); then
####	print Don\'t Split Yet.
####	print "I would sleep for 10hrs (36000 sec)"
####	COUNT_TIME=36000
####
####elif (( (${DIFF_TIME} >= 90000) && (${DIFF_TIME} <= 99999) )); then
####	print Don\'t Split Yet.
####	print "I would sleep for 9hrs (32400 sec)"
####	COUNT_TIME=32400
####
####elif (( (${DIFF_TIME} >= 80000) && (${DIFF_TIME} <= 89999) )); then
####	print Don\'t Split Yet.
####	print "I would sleep for 8hrs (28800 sec)"
####	COUNT_TIME=28800
####
####elif (( (${DIFF_TIME} >= 70000) && (${DIFF_TIME} <= 79999) )); then
####	print Don\'t Split Yet.
####	print "I would sleep for 7hrs (25200 sec)"
####	COUNT_TIME=25200
####
####elif (( (${DIFF_TIME} >= 60000) && (${DIFF_TIME} <= 69999) )); then
####	print Don\'t Split Yet.
####	print "I would sleep for 6hrs (21600 sec)"
####	COUNT_TIME=21600
####
####elif (( (${DIFF_TIME} >= 50000) && (${DIFF_TIME} <= 59999) )); then
####	print Don\'t Split Yet.
####	print "I would sleep for 5hrs (18000 sec)"
####	COUNT_TIME=18000
####
########elif (( (${DIFF_TIME} >= 40000) && (${DIFF_TIME} <= 49999) )); then
####if (( ${DIFF_TIME} > 40000 )); then
####	print Don\'t Split Yet.
####	#print "I would sleep for 4hrs (14400 sec)"
####	COUNT_TIME=14400
####
####elif (( (${DIFF_TIME} >= 30000) && (${DIFF_TIME} <= 39999) )); then
####	print Don\'t Split Yet.
####	#print "I would sleep for 3hrs (10800 sec)"
####	COUNT_TIME=10800
####
####elif (( (${DIFF_TIME} >= 20000) && (${DIFF_TIME} <= 29999) )); then
####	print Don\'t Split Yet.
####	#print "I would sleep for 2hrs (7200 sec)"
####	COUNT_TIME=7200
####
####elif (( (${DIFF_TIME} >= 10000) && (${DIFF_TIME} <= 19999) )); then
####	print Don\'t Split Yet.
####	#print "I would sleep for 1hr (3600 sec)"
####	COUNT_TIME=3600
####
####elif (( (${DIFF_TIME} >= 7000) && (${DIFF_TIME} <= 9999) )); then
####	print Don\'t Split Yet.
####	#print "I would sleep for 30mins (1800 sec)"
####	COUNT_TIME=1800
####
####elif (( (${DIFF_TIME} >= 5000) && (${DIFF_TIME} <= 6999) )); then
####	print Don\'t Split Yet.
####	#print "I would sleep for 15mins  (${COUNT_TIME_9} sec)"
####	COUNT_TIME=${COUNT_TIME_9}
####
####elif (( (${DIFF_TIME} >= 1000) && (${DIFF_TIME} <= 4999) )); then
####	print Don\'t Split Yet.
####	#print "I would sleep for 10mins  (${COUNT_TIME_6} sec)"
####	COUNT_TIME=${COUNT_TIME_6}
####
####elif (( (${DIFF_TIME} >= 0) && (${DIFF_TIME} <= 999) )); then
####	print Don\'t Split Yet.
####	#print "I would sleep for 5mins  (${COUNT_TIME_3} sec)"
####	COUNT_TIME=${COUNT_TIME_3}
####
####fi

typeset HOURS=$(( ${CURRENT_TIME} / 3600 ))
typeset PRE_MINUTES=$(( ${CURRENT_TIME} % 3600 ))
typeset MINUTES=$(( ${PRE_MINUTES} / 60 ))
typeset SECONDS=$(( ${PRE_MINUTES} % 60 ))

typeset HR_SECONDS=$(( ${HOURS} * 3600 ))
typeset HR_MINUTES=$(( ${MINUTES} * 60 ))
typeset TOTAL_SECONDS=$(( ${HR_SECONDS} + ${HR_MINUTES} + ${SECONDS} ))

print "#"
print CURRENT_TIME is: ${CURRENT_TIME}
print HOURS are: ${HOURS}
print MINUTES are: ${MINUTES}
print SECONDS are: ${SECONDS}
print HR_SECONDS are: ${HR_SECONDS}
print HR_MINUTES are: ${HR_MINUTES}
print TOTAL_SECONDS are: ${TOTAL_SECONDS}
print "#"

print COUNT_TIME is set to: ${COUNT_TIME}
print "#"
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
		#${BINDIR}/Time_Counter ${COUNT_TIME}
		print; print "#"
		STOP_LOOP=0
	fi
done
}
DO_THE_LOOP

print I\'m Done.
