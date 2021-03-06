#!/usr/bin/ksh

typeset GOAL_TIME=${1}
typeset GOAL_HRS=$(echo ${GOAL_TIME} | cut -d":" -f1)
typeset GOAL_MIN=$(echo ${GOAL_TIME} | cut -d":" -f2)
typeset GOAL_SEC=$(echo ${GOAL_TIME} | cut -d":" -f3)

typeset GOAL_TIME2=$(( (${GOAL_HRS} * 3600) + (${GOAL_MIN} * 60) + ${GOAL_SEC} ))

typeset CURR_HRS=$(date +%H)
typeset CURR_MIN=$(date +%M)
typeset CURR_SEC=$(date +%S)
typeset CURR_TIME=$(( (${CURR_HRS} * 3600) + (${CURR_MIN} * 60) + ${CURR_SEC} ))

typeset GOAL=$((${GOAL_TIME2} - ${CURR_TIME}))

typeset HOURS=$(( ${GOAL} / 3600 ))
typeset PRE_MINUTES=$(( ${GOAL}  % 3600 ))
typeset MINUTES=$(( ${PRE_MINUTES}  / 60 ))
typeset SECONDS=$(( ${PRE_MINUTES} % 60 ))

print "\tGOAL is: ${GOAL}"
print "\tHOURS are: ${HOURS}"
print "\tPRE_MINUTES are: ${PRE_MINUTES}"
print "\tMINUTES are: ${MINUTES}"
print "\tSECONDS are: ${SECONDS}"

typeset COUNT=0

MANUAL_MONITOR=YES
print MANUAL_MONITOR is set to: ${MANUAL_MONITOR}
print $0 Starting at: $(date)

print "Sleeping ${GOAL} Seconds. ( ${HOURS} hrs ${MINUTES} min ${SECONDS} sec)"

COUNT_EM() {
if [[ ${MANUAL_MONITOR} = 'YES' ]]
then
	until [[ ${COUNT} -gt ${GOAL} ]] ## count up to GOAL
	do
		COUNT_DOWN=$(( ${GOAL} - ${COUNT} ))
		typeset HOURS=$(( ${COUNT_DOWN} / 3600 ))
		typeset PRE_MINUTES=$(( ${COUNT_DOWN}  % 3600 ))
		typeset MINUTES=$(( ${PRE_MINUTES}  / 60 ))
		typeset SECONDS=$(( ${PRE_MINUTES} % 60 ))

		echo "\t\t${HOURS} hrs ${MINUTES} min ${SECONDS} sec  \r\c"
		((COUNT+=1))	## increment COUNT by 1
		sleep 1		## Acutally do the sleep for 1 second.
	done
	print
else
	sleep ${GOAL}
	print
fi
}

COUNT_EM

print
print $0 Finished at: $(date)
