#!/usr/bin/ksh

TESTDIR="/usr/local/bin/bcvscripts/testing"
CFG_FILE=${TESTDIR}/cfg.file
INSTANCE_FILE=${TESTDIR}/instances
TOTAL_INSTANCES=$(grep INSTANCES ${CFG_FILE} | cut -d":" -f2)

RPT_INSTANCE() {
	print Current Instance is: ${INSTANCE}
	print INSTANCE:${INSTANCE} > ${INSTANCE_FILE}
}

print Total Instances are: ${TOTAL_INSTANCES}
print

if [[ -f  ${INSTANCE_FILE} ]]
then
	print Instance file exists
	INSTANCE=$(( $(grep INSTANCE ${INSTANCE_FILE} | cut -d":" -f2) + 1 ))
	RPT_INSTANCE
else
	print Instance file does NOT exist
	INSTANCE=${INSTANCE:-1}
	RPT_INSTANCE
fi

print; print Instance file now contains:
cat ${INSTANCE_FILE}
print

if (( "${INSTANCE}" == "${TOTAL_INSTANCES}" ))
then
	print NOW
	rm ${INSTANCE_FILE}
else
	print NOT YET
fi
