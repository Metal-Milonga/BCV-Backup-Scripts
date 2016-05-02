#!/usr/bin/ksh

# Version - 3.0
# Date - May 2, 2002

SERVER=$1
BINDIR="/usr/local/bin/bcvscripts/testing"
CFGDIR="/usr/local/bin/bcvscripts/testing"
#TTCFGFILE=${CFGDIR}/time.cfg
TTCFGFILE=${CFGDIR}/time2.cfg
	#server09-STime:234500
	#server16-STime:234500
export MANUAL_MONITOR=YES

Determine_Wait() {

SPLIT_TIME=$(grep ${SERVER}-STime ${TTCFGFILE}  | cut -d":" -f2-)
SPLIT_TIME_2=$(grep ${SERVER}-STime ${TTCFGFILE}  | cut -d":" -f2- | sed "s/://g")
SPLIT_HR=$(echo ${SPLIT_TIME} | cut -d":" -f1)
SPLIT_MIN=$(echo ${SPLIT_TIME} | cut -d":" -f2)
SPLIT_SEC=$(echo ${SPLIT_TIME} | cut -d":" -f3)
SPLIT_TOT_SEC=$(( (${SPLIT_HR} * 3600) + (${SPLIT_MIN} * 60) + ${SPLIT_SEC} ))

CURRENT_TIME=$(date +%H:%M:%S)
CURRENT_TIME_2=$(date +%H:%M:%S | sed "s/://g")
CURRENT_HR=$(echo ${CURRENT_TIME} | cut -d":" -f1)
CURRENT_MIN=$(echo ${CURRENT_TIME} | cut -d":" -f2)
CURRENT_SEC=$(echo ${CURRENT_TIME} | cut -d":" -f3)
HR_SECONDS=$(( ${CURRENT_HR} * 3600 ))
HR_MINUTES=$(( ${CURRENT_MIN} * 60 ))
CURRENT_TOT_SEC=$(( ${HR_SECONDS} + ${HR_MINUTES} + ${CURRENT_SEC} ))

DIFF_TIME=$(( ${SPLIT_TOT_SEC} - ${CURRENT_TOT_SEC} ))
ADJ_HRS=$(( ${DIFF_TIME} / 3600 ))
ADJ_TIME=$(( ${ADJ_HRS} * 60 ))
COUNT_TIME=$(( ${DIFF_TIME} - ${ADJ_TIME} ))

Print_Variables() {
	print; print "#####"; print
	print -n SPLIT_TIME is: ${SPLIT_TIME} \\t
	print SPLIT_TIME_2 is: ${SPLIT_TIME_2}
	print -n SPLIT_HR is: ${SPLIT_HR} \\t\\t
	print -n SPLIT_MIN is: ${SPLIT_MIN} \\t
	print SPLIT_SEC is: ${SPLIT_SEC}
	print "#"
	print -n CURRENT_TIME is: ${CURRENT_TIME} \\t
	print CURRENT_TIME_2 is: ${CURRENT_TIME_2}
	print -n CURRENT_HR is: ${CURRENT_HR} \\t\\t
	print -n CURRENT_MIN is: ${CURRENT_MIN} \\t
	print CURRENT_SEC is: ${CURRENT_SEC}
	print -n HR_SECONDS are: ${HR_SECONDS} \\t
	print HR_MINUTES are: ${HR_MINUTES}
	print "#"
	print -n SPLIT_TOT_SEC is: ${SPLIT_TOT_SEC} \\t
	print CURRENT_TOT_SEC are: ${CURRENT_TOT_SEC}
	print "#"
	print -n DIFF_TIME is: ${DIFF_TIME} \\t
	print -n ADJ_HRS are: ${ADJ_HRS} \\t
	print ADJ_TIME is: ${ADJ_TIME} seconds
	print COUNT_TIME is set to: ${COUNT_TIME}
}
Print_Variables

print "#"
}

DO_THE_LOOP(){
STOP_LOOP=1
until (( ${STOP_LOOP} == 0 ))
do
	Determine_Wait

	if (( ${CURRENT_TIME_2} > ${SPLIT_TIME_2} ))
	then
		print It\'s Time to Split.
		STOP_LOOP=0
		print "#"
	else
		${BINDIR}/Time_Counter2.sh ${COUNT_TIME}
		print; print "#"

		##STOP_LOOP=0 # for testing
	fi
done
}
DO_THE_LOOP

print I\'m Done. $(date)
