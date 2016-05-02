#!/usr/bin/ksh
# Script: Full-Monitor.sh

MANUAL_MONITOR=YES
BASEDIR=/usr/local/bin/bcvscripts
LETCDIR=${BASEDIR}/etc
LTMPDIR=${BASEDIR}/tmp
LLIBDIR=${BASEDIR}/lib
CONFIGFILE=${LETCDIR}/bcv_scripts.conf
SYMCLIDIR=/usr/symcli/bin

FPATH=/usr/local/bin/bcvscripts/lib
autoload Time_Counter

FULL_MONTIOR_STATUS=${LTMPDIR}/FULL_MONITOR.STAT

#set -A ALL_DGS $(grep -e server16_DG -e X_server16_DG -e server16_DG -e X_server16_DG -e server20_DG -e X_server20_DG ${CONFIGFILE} | cut -d":" -f2 | sed "s/,/ /g")
set -A ALL_DGS $(grep -e server16_DG ${CONFIGFILE} | cut -d":" -f2 | sed "s/,/ /g")

typeset SYNCHRONIZED=NO
GROUP_COUNT_ORIG=0
GROUP_COUNT=${GROUP_COUNT_ORIG}

print ALL_DGs are: ${ALL_DGS[*]}

until [[ ${SYNCHRONIZED} = YES ]]
do
	print

	for DG in ${ALL_DGS[*]}
	do

		${SYMCLIDIR}/symmir -g ${DG} verify -synched > /dev/null
		SYNCHED_STAT=${?}
	
		${SYMCLIDIR}/symmir -g ${DG} verify -syncinprog > /dev/null
		INPROG_STAT=${?}

		SYNCHSTAT=${DG}_synched
		INPROGSTAT=${DG}_inprog

		MB_CHECK=$(${SYMCLIDIR}/symmir -g ${DG} query | grep -e "MB(s)" | sed "s/  */:/g" | cut -d":" -f4)
		print ${DG} status: Synch stat is ${SYNCHED_STAT}. Syncinprog stat is ${INPROG_STAT}. MEG left ${MB_CHECK}.
	
		if [[ ${SYNCHED_STAT} -eq 0 ]]
		then
			GROUP_COUNT=$(( ${GROUP_COUNT} + 1 ))
		fi
	done

	print
	print Group Count is: ${GROUP_COUNT}
	if [[ ${GROUP_COUNT} -eq ${#ALL_DGS[*]} ]]
	then
		print The Device Groups are fully established.
		typeset SYNCHRONIZED=YES
	else
		print The Device Groups are NOT YET established.
		print Resetting Group Count to ${GROUP_COUNT_ORIG}.
		GROUP_COUNT=${GROUP_COUNT_ORIG}
		typeset SYNCHRONIZED=NO
	fi

	if [[ ${SYNCHRONIZED} != YES ]]
	then
		print
		Time_Counter 600
		print
	fi

done

print Full Monitor Script finished at: $(date)
