#!/usr/bin/ksh

NO_Options() {
#set -x

# Check the syntax of the arguements passed to the script and make sure they are correct.
print "\$# is: $#"
print "\$@ is: $@"
print "\$* is: $*"

if [[ $# -eq 0 ]]
then
	print; print
	print BCV-Est.sh Command-Line Syntax Error.
	print ${USAGE}
	exit
	print; print
fi
}

CORRECT_OPTIONS() {

OPTIONS=$( echo $* | sed "s/-//g")
print OPTIONS are now: ${OPTIONS}
print

if [[ ${OPTIONS} = ?([BFMW])?([BFMW])?([BFMW])?([BFMW])"S"?(' ')"server"[0-9][0-9]?(' 'C?(' ')+([._-a-zA-Z0-9]))  ||\
      ${OPTIONS} = ?([BFMW])?([BFMW])?([BFMW])?([BFMW])?(' 'C?(' ')+([._-a-zA-Z0-9]))" S"?(' ')"server"[0-9][0-9]    ||\
      ${OPTIONS} = ?([BFMW])?([BFMW])?([BFMW])?([BFMW])?(C?(' ')+([._-a-zA-Z0-9]))" S"?(' ')"server"[0-9][0-9]    ||\
      ${OPTIONS} = ?(C?(' ')+([._-a-zA-Z0-9]))" S"?(' ')"server"[0-9][0-9]" "?([BFMW])?([BFMW])?([BFMW])?([BFMW]) ||\
      ${OPTIONS} = "S"?(' ')"server"[0-9][0-9]?(' 'C?(' ')+([._-a-zA-Z0-9]))" "?([BFMW])?([BFMW])?([BFMW])?([BFMW]) ||\
      ${OPTIONS} = "S"?(' ')"server"[0-9][0-9]" "?([BFMW])?([BFMW])?([BFMW])?([BFMW])?(' 'C?(' ')+([._-a-zA-Z0-9])) ||\
      ${OPTIONS} = "S"?(' ')"server"[0-9][0-9]" "?([BFMW])?([BFMW])?([BFMW])?([BFMW])?(C?(' ')+([._-a-zA-Z0-9])) ||\
      ${OPTIONS} = ?(C?(' ')+([._-a-zA-Z0-9]))" "?([BFMW])?([BFMW])?([BFMW])?([BFMW])" S"?(' ')"server"[0-9][0-9] ||\
      ${OPTIONS} = ?(C?(' ')+([._-a-zA-Z0-9]))" "?([BFMW])?([BFMW])?([BFMW])?([BFMW])"S"?(' ')"server"[0-9][0-9] ]]
then
	print Inside Function, OPTIONS are: ${OPTIONS}
	print
else
	print
	print Inside Function, OPTIONS are: ${OPTIONS}
	print
	print BCV-Est.sh Command-Line Syntax Error.
	print ${USAGE}
	print; print
	exit
fi
}

USAGE=$(cat << END_OF_USAGE 
usage: BCV-Est.sh -[B] -[F] -[M] -[W] -S servername [-C new_config_file]  \n
\t The "S" option is NOT optional.  It MUST be supplied with a valid servername following. \n\n
\t The M, F, B, C options do not have to be used. They are optional. \n
\t By default the Establish will be run in Incremental mode with NO visual monitor, and Backups turned OFF. \n\n
\t -F = Will run a FULL Establish \n
\t -M = Will display information on the screen as the script monitors the establish. \n
\t -W = Will force the Split to wait until the time set in the Config file. \n
\t\t	It was designed for use in crontab. Data Services needs the split to happen at specfic times. \n
\t\t	Otherwise, the split will take place as soon as the Establish has finished. \n
\t -B = Should only be used with crontab.  It runs the OmniBack backup job at the end of the script. \n
\t -C = Designate a different Config file to be used. \n\n
\t As always you can combine command that do not take arguements behind one dash.\n
\t Example:\t -FMC new_config_file -S servername \n
\t OR:\t\t -BFS servername -C new_config_file
\n\n
END_OF_USAGE)

NO_Options $@
CORRECT_OPTIONS $@

while getopts ":BFMWS:C:" opt
do
	case $opt in
		M )	MAN_MONITOR=YES
			## print Manual Monitoring is set to: ${MAN_MONITOR}
			;;
		F )	EST_TYPE=FULL
			## print Establish Type is set to: ${EST_TYPE}
			;;
		S )	SERVER=${OPTARG}
			## print SERVER is set to: ${SERVER}
			;;
		B )	RUN_BACKUP=YES
			## print RUN_BACKUP is set to: ${RUN_BACKUP}
			;;
		C )	CONFIG_FILE=${OPTARG}
			## print CONFIG_FILE is set to: ${CONFIG_FILE}
			;;
		W )	WAIT_TO_SPLIT=YES
			;;
		\? )	print ${USAGE}
			print exiting
			exit
	esac
done

BCVETCDIR=/usr/local/bin/bcvscripts/etc
BCVCFGFILE=${BCVETCDIR}/bcv_scripts.conf.test

EST_TYPE=${EST_TYPE:=incr}
RUN_BACKUP=${RUN_BACKUP:=NO}
CONFIG_FILE=${CONFIG_FILE:=${BCVCFGFILE}}
MAN_MONITOR=${MAN_MONITOR:=NO}
WAIT_TO_SPLIT=${WAIT_TO_SPLIT:=NO}

print SERVER is set to: ${SERVER}
print Establish Type is set to: ${EST_TYPE}
print RUN_BACKUP is set to: ${RUN_BACKUP}
print CONFIG_FILE is set to: ${CONFIG_FILE}
print Manual Monitoring is set to: ${MAN_MONITOR}
print Wait to Split is set to: ${WAIT_TO_SPLIT}
print "#"
print Running Script ${0}
print Finished Script ${0}
