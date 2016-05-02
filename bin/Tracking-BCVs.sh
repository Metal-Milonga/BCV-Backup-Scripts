#!/usr/bin/ksh

LBASEDIR=/usr/local/bin/bcvscripts
LBINDIR=${LBASEDIR}/bin
LETCDIR=${LBASEDIR}/etc
LLOGDIR=${LBASEDIR}/logs/Tracking
SYMCLIBIN=/usr/symcli/bin

CONFIG_FILE=${LETCDIR}/tracking.conf

set -A TRACKING_GROUPS $(grep ^DGS ${CONFIG_FILE} | cut -d":" -f2 | sed "s/,/ /g")

for DG in ${TRACKING_GROUPS[*]}
do
	DG_LOGFILE=${LLOGDIR}/${DG}.log
	
	if [ -f ${DG_LOGFILE} ]
	then
		:
	else
		touch ${DG_LOGFILE}
	fi

	DATE=$(date +%m%d%y-%H:%M:%S)

	set -A TRACKS $( ${SYMCLIBIN}/symmir -g ${DG} query | grep "Track(s)" | sed "s/  */ /g" | cut -d" " -f3,4 )
	SD_TRACKS=${TRACKS[0]}
	BCV_TRACKS=${TRACKS[1]}
	TOTAL=$(( ${SD_TRACKS} + ${BCV_TRACKS} ))

	print "${DATE},${DG},${SD_TRACKS},${BCV_TRACKS},\tTOTAL: ${TOTAL}" >> ${DG_LOGFILE}
done
