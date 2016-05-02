#!/usr/bin/ksh
#
# Widden your terminal window all the way across your screen.
# It will be easier to read the script.
#
# Jump to line 270. That's about where the main script starts.
#
# Program - BCV-Est.sh
# Version - 1.00
# Author - David A. Holton
# Date - April 19, 2002
# Production Date - April 19, 2002
#
# Description - The script begins the process of establishing the HumanSoft
#		BCVs to their Standard Devices.  It makes use of external
#		Functions that can be reused by other scripts.  This allows
#		parts of the script to be disabled to test or run other parts.
#
# USAGE: BCV-Est.sh [-B] [-F] [-M] -S servername [-s split_mode_arguement] [-C new_config_file]
#
#	Place in crontab to run with STDOUT & STDERR redirected to a
#	log file in the logs directory. i.e.:
#
#	0 2 * * 6,0 /usr/local/bin/bcvscripts/bin/BCV-Est.sh -FBS server09 -s wait > /usr/local/bin/bcvscripts/logs/server09_BCV_LOG 2>&1
#	0 2 * * 1-5 /usr/local/bin/bcvscripts/bin/BCV-Est.sh -BS server09 -s wait > /usr/local/bin/bcvscripts/logs/server09_BCV_LOG 2>&1
#
#	OR
#
#	Disable any function you do not want to run, and run the script	from
#	the command line.
#	This will work in most cases, but errors may result for functions
#	containing LVM commands
#	However, it should not break anything.
#
#	The "S" option is NOT optional.  It MUST be supplied with a valid
#	servername following.
#
#	The servername MUST start with server
#
#	Defaults are:
#		Establish in Incremental mode
#		Visual Monitor OFF
#		Backups OFF
#		Config File: /usr/local/bin/bcvscripts/etc/bcv_scripts.conf
#
#	The F, M, W, C, B options do not have to be used. They are optional.
#		-F = Will run a FULL Establish
#		-M = Will display information on the screen as the script
#			performs any sleep function.
#		-s split_mode_arguement
#			non-stop This is the default an is executed if no -s option
#				is given.
#			wait	Will cause the script to wait until a preset time before
#				Splitting the BCVs.  It was designed to be used with
#				crontab since Data Services relies on the Split
#				taking place a set times.
#				The time to split is set in the Config File.
#				DON'T use it on the command line unless you have
#				properly set the time in the Config File. You could
#				end up waiting for a very long time.
#			cmd	For running the script from the commandline and you
#				want the script to wait until you give it the signal
#				to split the BCVs.  The script will wait on the
#				commandline from the terminal you started the script
#				on.
#			pipe	Run the script from crontab or commandline, but the
#				script will wait to split the BCVs until it gets a
#				signal from a named pipe.  There is a special log
#				file written when the pipe mode is used.  This is in
#				case the script was started commandline, but you are
#				no longer at that terminal when it is time to split
#				the BCVs. The log file is in the log file directory.
#				See the File Locations section below for where that is.
#		-C = Designate a different Config file to be used. It MUST be
#			in the /usr/local/bin/bcvscripts/etc directory.
#			The name of the config file can be any combination of
#			letters, numbers, underscore, dash, and dot
#		-B = Should only be used with crontab.  It runs the OmniBack
#			backup job at the end of the script.
#			The B option creates some files that are needed to
#			figure out when the Backup jobs can be run, and
#			if the filesystems and drives are ready.  Running
#			the script from the commandline with the -B option
#			could cause you some headaches.
#
#	As always you can combine command options that do not take arguements
#	behind one dash.
#	Examples:	BCV-Est.sh -S server09
#			BCV-Est.sh -FMS server09
#			BCV-Est.sh -M -Sserver09 -C Config_File-123.Dave
#			BCV-Est.sh -FMCConfig_File-123.Dave -S server09
#			BCV-Est.sh -C Config_File-123.Dave -FM -S server09
#			BCV-Est.sh -S server09 -C Config_File-123.Dave -M
#
#
# Functions - The location of the functions are declared in the FPATH variable.
#		Be careful modifying functions since other scripts may rely on
#		them.
#
# File Locations - This script requires certain files and directories in order
#		to function properly.
#   /usr/local/bin/bcvscripts -		This is the base directory for the BCV
#					script file structure
#   /usr/local/bin/bcvscripts/bin -	This is the main executable dir. This
#					script resides here.
#   /usr/local/bin/bcvscripts/etc -	The configuration file is here. It
#					supplies the script with Servers,
#					Filesystems, Device Groups, Backup,
#					Notification lists, other basic
#					information to work
#					with. AS well as which Filesystems and
#					Device Groups must use -exact mode
#					establish.
#   /usr/local/bin/bcvscripts/lib -	Contains the functions the script uses.
#   /usr/local/bin/bcvscripts/tmp -	Holds files the script creats each time
#					it runs.
#   /usr/local/bin/bcvscripts/logs -	Contains log files to record the results
#					of the script.
#   /usr/local/bin/bcvscripts/testing - Contains a lot of test scripts used to
#					work out logic contained in the functions.
#					They can be helpful for troubleshooting
#					complicated sections of code before
#					making changes to production functions.
#
# History - The basic format, and modular approach was taken from the
#		Psoft-Auto-Est.sh script V3.01
#
###############################################################################
# Modification history
# Date     Who		What was modified.
# -------- ------------	------------------
# 04/25/02 Dave Holton	Added the -W option.
# 04/25/02 Dave Holton	After adding -W option, the Oracle Hot Backup Scripts
#			were not incorporated into the waiting time.  Put them
#			both in the Split_BCV function, and removed them from
#			the main script. Confirmed fixed.
# 04/26/02 Dave Holton	Start Omniback Job had a bug when it evaluated the File-
#			Systems to see if they were mounted. The Ready Status 
#			variable was not being reset.  Fixed. Confirmed fixed.
# 04/27/02 Dave Holton	Pull_Oracle_Logs modified.
# 05/23/02 Dave Holton	Put in version 2 of Time_Counter function. It will
#			figure out the hours, minutes, and seconds contained
#			in the GOAL variable. And, now on the countdown line
#			it displays hours, minutes, and seconds as they count
#			down.
# 05/23/02 Dave Holton	Added the Determine_Split_Wait function. It is used with
#			Version 2 of the Time_Counter function.  The Determine_
#			Split_Wait function figures out how much time between
#			the Current time and the split time, and passes this
#			value to the Time_Counter function.  This way it will do
#			less sleeps until time to split.
# 05/24/02 Dave Holton	In the Split_BCV function, I changed the comparison of
#			the current time to the split time to be >= rather than
#			just > than. The Time_Counter ended exactly at the split
#			time, and ran through several cycles of countdown until
#			the current time was 1 second more than the split time.
# 06/12/02 Dave Holton	In the Determine_Split_Wait function, changed the way
#			the COUNT_TIME variable gets its value based on how
#			the Manual Monitor option is set.  If it is set to YES
#			the COUNT_TIME variable will be adjusted to allow for the
#			overhead generated by the Time_Counter function printing
#			information to the screen.  If Manual Monitoring is set
#			to NO, the the COUNT_TIME variable is not adjusted.
# 07/09/02 Dave Holton	Cleaning up the Email message to be smaller, more 
#			concise and easier & faster to read.
# 07/26/02 Dave Holton  Changed the grep for OMNIBACK_OBJ to ^OMNIBACK_OBJ. I
#                       had added a comment to the config file that included
#                       the word Foobar.  The script grepped out both instances
#                       of Foobar, and the backups never started as a result.
#                       Also, changed the value of the variable to be all
#                       caps insetead of mixed case.  Changed the config file
#                       as well.
#                       Tested and confirmed it worked.
# 07/28/02 Dave Holton	Changed the case of FOOBAR back to mixed case. It caused
#			problems since the OmniBack scheme was in mixed case. I
#			need to change the OmniBack scheme's name before
#			changing the script.
# 11/26/02 Dave Holton	Added code to the Split_BCVs function to check for a
#			SPLIT_LOCK file.  If the file
#			is present, then another instance of the script is
#			running a split routine. In that case, sleep for 900
#			seconds and check again. If the file is not there then
#			it is okay to split the BCVs, but first we touch the
#			SPLIT_LOCK file so no other instances will error out
#			while we are splitting.  Once we are finished, the
#			script removes the SPLIT_LOCK FILE.
# 11/28/02 Dave Holton	Pulled the Define_VG_Variables and 
#			What_Are_The_Variables internal functions and made
#			them both external functions. Now all external
#			functions will call them as needed.  This was done to
#			resolve one VG having more than one lvol in it. It was
#			difficult to find and update the same function in
#			in multiple external functions.
# 11/29/02 Dave Holton	Tweaked the Start_Omniback function.
# 01/23/03 Dave Holton	Added the UNMOUNT_COUNT variable to Unmount_Filesystems
#			function. In an effort to simplify the reports and make
#			them more uniform.
# 03/26/03 Dave Holton	Removed the huge evaluation sequence from Command_Options
#			to see if the command line was right.  Now letting
#			getopts do all work instead of trying to figure out each
#			possible combination. Adjusted the getopts SERVER variable
#			assignment to test for a valid server passed on the
#			command line.
# 03/28/03 Dave Holton	Command_Options:
#			Added the commandline option -s to signify SPLIT_MODE
#			variable as NON_STOP, WAIT, PIPE, or CMD.
#			This does away with the -W option. The WAIT
#			option waits until the preset time in the config file.
#			The PIPE function waits for a signal from a FIFO named
#			pipe in the etc directory.  The CMD option waits for
#			an entry on the command line the script is running on.
#			Of course, NON_STOP does not wait at all.
# 03/28/03 Dave Holton	Split_BCVs module:
# 			Removing the WAIT_TO_SPLIT variable and replacing it
#			with the SPLIT_MODE variable. Adding code for the
#			PIPE, CMD, and NON_STOP split modes.  WAIT works the
#			same as WAIT_TO_SPLIT variable did.
# 04/10/03 Dave Holton	Added fuser -ku filesystem just before the umount.  This
#			will kick off any users that may be logged into the
#			system and parked on the filesystem.
# 08/02/04 david holton Changed the variables (in Declare_General_Variables)
#                       ORA_START_HB=ora_start*backup.log
#                       ORA_STOP_HB=ora_stop*backup.log
#                       to ora_start*backup.log & ora_stop*backup.log so that
#                       the Pull function will get all the logs from srvr09. 
#                       srvr09 has a separate log for each Oracle instance.
#                       Once it is verified to work, I will put in more code
#                       to check the scripts in a more streamlined manner.
# 08/26/04 david HOlton	Replaced the Pull_Oracle_Logs function with the new
#			Oracle_Logs_Verify function.  It has better error
#			checking and pulls over all the files since Oracle
#			now produces a separate file for each instance.
#
###############################################################################
# To Do List
# * Check for proper function of r-commands.
# * Set up an option to skip the BCV split.  It would start the establish,
#	monitor it, and then exit the script.
# * Remove case statements in functions that rely on hardcoded server names.
# * Set up PATH Variables for all commands.
# * Set up Oracle Notification list for errors found in Start/Stop Hot Backup
# * Determine the OMNIBACK_OBJ variable from the config file. Remove the
#       assignment of the variable from this function.  There are two many
#       places to change and make sure they are sync'ed.
# * One possible way to resolve the problem with comments in the config file
#	is to have the script take the config file and create a runtime
#	config file each time it runs.  In making the runtime config file
#	it would strip out all comment lines and blank lines.  THen it would
#	only contain active lines needed by the script. Then remove it once
#	the script is finished.
# * In the case where a special instance of the script needs to run while the
#	normal instances are running out of cron, it may help to work in some
#	kind of unique identifier that would be given on the commandline so
#	the special instance of the script would not interfer with the run of
#	the normal scripts.
#
###############################################################################
# Done
#
# 05/23/02
# 	Fix the Wait to split function to figure out how long to sleep.  Can be
#       done with a case statement with set times to sleep for certain
#       difference between the Current Time and the Split Time.
# 11/28/02
#	*Resolve the psfiles1 VG having 3 lvols. Incorporate code.
#	*Separate the Define_VG_Variables internal function into a separate 
#	function that can be called throughout the script.
#	See the Define_VG_Variables_Test function.
#	*Separate the What_Are_The_Variables internal function into a separate 
#	function that can be called throughout the script.
# 03/26/03
#	Put in streamlined Command Line evaluation commands from CO4.sh
#
###############################################################################
# set -x
# set -n
umask 077
###############################################################################

##### MAIN SCRIPT

##### Declaring the path to find the functions.
FPATH=/usr/local/bin/bcvscripts/lib

##### Autoload the functions as they are needed.
autoload Command_Options Declare_General_Variables Declare_VolumeGroup_Variables Declare_DeviceGroup_Variables
autoload Declare_OmniBack_Variables OOP_Functions Sleeper Time_Line Time_Counter
autoload Unmount_Filesystems DEactivate_VolumeGroups Export_VolumeGroups
autoload Establish_BCVs Monitor_BCV_Establish Verify_BCV_Sync_Started Verify_BCV_Sync_Finished
autoload Start_Oracle_HotBackup_Mode Split_BCVs_NOHOTBCKUP Verify_BCV_Split Stop_Oracle_HotBackup_Mode
autoload Import_VolumeGroups Activate_VolumeGroups FSCK_and_Mount_Filesystems
autoload ORacle_Log_Verify Check_LVM_Errors Notify Start_OmniBack_Job
autoload Verify_Variables Clean_Up Print_Start Print_End Determine_Split_Wait
autoload Define_VG_Variables What_Are_The_Variables

##### Functions.  See the individual functions in /usr/local/bin/bcvscripts/lib

Command_Options $@		# Makes sure the options passed to the script are correct
				# And sets up some initial variables for the rest of the script

Print_Start			# Just prints main script start messages for the Log files.

	##### Set up variables and OOP functions for the rest of the script
Declare_General_Variables	# Declare the misc general variables.
Declare_VolumeGroup_Variables	# Declare VolumeGroup variables specific to the server
Declare_DeviceGroup_Variables	# Declare DeviceGroup variables specific to the server
Declare_OmniBack_Variables	# Declares Variables for OmniBack Jobs
OOP_Functions			# Sets up Object Oriented Functions in the script's environment

	##### Prepare the VGs and Filesystems for BCV Establish and split.
Unmount_Filesystems		# Attempts to UNmount all Filesystems.
DEactivate_VolumeGroups		# Relies on Unmount_Filesystems. Deactivates all VGs.
Export_VolumeGroups		# Relies on DEactivate_VolumeGroups.
				# Exports any VGs requiring -exact mode establish

	##### BCV operations: Start the Establish, monitor progress, Split. Verify each operation.
#Establish_BCVs			# Begin the BCV Establish operations
#Verify_BCV_Sync_Started		# Make sure the Establish operation started for all DGs.
Monitor_BCV_Establish		# Monitors the Establish and continues the script once
				# all establish operations are completed.
Verify_BCV_Sync_Finished	# Verifies that all Establish operations were completed.
Split_BCVs_NOHOTBCKUP			# Split the BCVs from the Standard Devices.
Verify_BCV_Split		# Verify the Split completed successfully for all DGs.

	##### Restore the VG and Filesystem environment to prepare for backup
Import_VolumeGroups		# Import any VGs requiring -exact mode establish
Activate_VolumeGroups		# Activate all VGs
FSCK_and_Mount_Filesystems	# Run FSCK & Mount all Filesystems.
ORacle_Log_Verify		# Pulls a copy of the Oracle Hot Backup Logs.

Check_LVM_Errors

	##### Start the Backups
Start_OmniBack_Job		# Starts the backups once the filesystems are ready and
				# the specific tape drive is ready.

Verify_Variables		# In productions it gathers the environment into a file
				# to be used for troubleshooting.  Used for testing otherwise.
Clean_Up			# Tar up the logs, and temp files.

Print_End			# Just prints main script end messages for the log files.

Notify Final			# Emails listed staff the email report.
