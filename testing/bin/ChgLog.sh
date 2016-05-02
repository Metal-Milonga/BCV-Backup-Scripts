#!/usr/bin/ksh

BASEDIR=/usr/local/bin/bcvscripts/testing
LLIBDIR=${BASEDIR}/lib
LETCDIR=${BASEDIR}/etc
LBINDIR=${BASEDIR}/bin

CHGDIR=${BASEDIR}/etc
CHGFILE=${CHGDIR}/ChangeLog

clear; print

File_Lists() {
for DIR in BIN ETC LIB
do
	LOOP1() {
	print ${BASEDIR}/${DIR}
	eval "LS_DIR=L${DIR}DIR"
	eval ls \$${LS_DIR}

	print
	print "Anything to changed in the ${DIR} directory? \c"
	read YESORNO
	if [[ ${YESORNO} = @([Yy])?([eE][sS]) ]]
	then
		print "What file(s) are you changing in ${DIR}? \c"
		read FILE_ANSWER
		set -A ARRAY_FILES ${FILE_ANSWER}
		BIG_LIST=$(cat << END_OF_LIST
			\t${BIG_LIST}\n
			\t${BASEDIR}/${DIR}\n
			\t\t${ARRAY_FILES[*]}
END_OF_LIST)
	elif [[ ${YESORNO} = @([Nn])?([Oo]) ]]
	then
		:
	else
		print
		print "!!!!!!!"
		print "\tWhat? Try again....y[es] or n[o]"
		print
		LOOP1
	fi
	print
	}
	LOOP1
done

#print "${BIG_LIST}"
}

Changes() {
print "Where any major commands commented out?"
read COMMENT_OUT
if [[ ${COMMENT_OUT} = @([Nn])?([Oo]) ]]
then
	COMMENT_OUT="Nothing was commented out."
else
	COMMENT_OUT="Major commands were commented out."
	print "What was commented out: "
	read WHAT
fi
print "What are you changing and why:"
read EXPLAIN
}

Change_Message() {
MESSAGE=$(cat << END_OF_TEXT
#####################################################
\n
$(date)\n
${LOGNAME} changed:\n
\t Files Changed:
\t ${BIG_LIST}\n\n
\t Changes:\n
\t ${COMMENT_OUT}\n
\t\t ${WHAT}\n
\t ${EXPLAIN}\n
END_OF_TEXT)

print ${MESSAGE} >> ${CHGFILE}
print Changes recorded in the ${CHGFILE}
print
}

Check_Main_Script() {
grep -q -e "^#Command_Options" \
	-e "#Print_Start" \
	-e "#Declare_General_Variables" \
	-e "#Declare_VolumeGroup_Variables" \
	-e "#Declare_DeviceGroup_Variables" \
	-e "#Declare_OmniBack_Variables" \
	-e "#OOP_Functions" \
	-e "#Unmount_Filesystems" \
	-e "#DEactivate_VolumeGroups" \
	-e "#Export_VolumeGroups" \
	-e "#Establish_BCVs" \
	-e "#Verify_BCV_Sync_Started" \
	-e "#Monitor_BCV_Establish" \
	-e "#Verify_BCV_Sync_Finished" \
	-e "#Split_BCVs" \
	-e "#Verify_BCV_Split" \
	-e "#Import_VolumeGroups" \
	-e "#Activate_VolumeGroups" \
	-e "#FSCK_and_Mount_Filesystems" \
	-e "#Pull_Oracle_Logs" \
	-e "#Check_LVM_Errors" \
	-e "#Start_OmniBack_Job" \
	-e "#Verify_Variables" \
	-e "#Clean_Up" \
	-e "#Print_End" \
	-e "#Notify Final" \
${LBINDIR}/BCV-Est.sh

if [[ $? = 0 ]]
then
	print There are major functions still commented out in the Main Script.
	print
else
	print The Main Script seems to be fine. Check it anyway.
	print
fi
}

File_Lists
Changes
Change_Message
Check_Main_Script
