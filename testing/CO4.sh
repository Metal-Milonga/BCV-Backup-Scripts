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

EVALUATE_OPTIONS() {

OPTIONS=$( echo $* | sed "s/-//g")
print OPTIONS are now: ${OPTIONS}
print

OPTION_W=$(echo ${OPTIONS} | grep W )
OPTION_I=$(echo ${OPTIONS} | grep I )

if [[ -n ${OPTION_W} && -n ${OPTION_I} ]]
then
	print
	print Inside Function, OPTIONS are: ${OPTIONS}
	print
	print BCV-Est.sh Command-Line Syntax Error.
	print ${USAGE}
	print; print
	exit
else
	print Inside Function, OPTIONS are: ${OPTIONS}
	print
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
EVALUATE_OPTIONS $@

while getopts ":BC:D:FIMs:S:W" opt
do
	case $opt in
		B )	RUN_BACKUP=YES
			## print RUN_BACKUP is set to: ${RUN_BACKUP}
			;;
		C )	CONFIG_FILE=${OPTARG}
			## print CONFIG_FILE is set to: ${CONFIG_FILE}
			;;
		D )	DEBUG_MODE=$(echo ${OPTARG} | tr "[:lower:]" "[:upper:]" )
			if [[ ${DEBUG_MODE} != @(FULL|STEP) ]]
			then
				print "Option D (Debug Mode) was not correct!"
				print
				#print ${USAGE}
				exit
			fi
			;;
		F )	EST_TYPE=FULL
			## print Establish Type is set to: ${EST_TYPE}
			;;
		I )	INTERACTIVE=YES
			;;
		M )	MAN_MONITOR=YES
			## print Manual Monitoring is set to: ${MAN_MONITOR}
			;;
		s )	SPLIT_MODE=$( echo ${OPTARG} | tr "[:lower:]" "[:upper:]" )
			#print Split Mode set to: ${SPLIT_MODE}
			if [[ ${SPLIT_MODE} != @(WAIT|PIPE|CMD|NON_STOP) ]]
			then
				print "Option s (Split Mode) was not correct!"
				print "Split Mode set to: ${SPLIT_MODE}"
				print
				#print ${USAGE}
				exit
			fi
			;;
		S )	SERVER=${OPTARG}
			#if [[ ${SERVER} != @(q|r)"ta1cu"[0-9][0-9] ]]
			#if [[ ${SERVER} != "server"[0-9][0-9] ]]
			if [[ ${SERVER} != "server"@(09|16|20) ]]
			then
				print "Option S (Server) was not correct!"
				print
				#print ${USAGE}
				exit
			fi
			## print SERVER is set to: ${SERVER}
			;;
		\? )	print "WHAT!!"
			#print ${USAGE}
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
SPLIT_MODE=${SPLIT_MODE:=NON_STOP}
INTERACTIVE=${INTERACTIVE:=NO}
DEBUG_MODE=${DEBUG_MODE:=NO}

print SERVER is set to: ${SERVER}
print Establish Type is set to: ${EST_TYPE}
print RUN_BACKUP is set to: ${RUN_BACKUP}
print CONFIG_FILE is set to: ${CONFIG_FILE}
print Manual Monitoring is set to: ${MAN_MONITOR}
print Split Mode is set to: ${SPLIT_MODE}
print Interactive Mode is set to: ${INTERACTIVE}
print Debug Mode is set to: ${DEBUG_MODE}
print "#"
print Running Script ${0}
print Finished Script ${0}
