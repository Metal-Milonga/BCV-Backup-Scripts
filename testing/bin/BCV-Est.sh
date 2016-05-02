#!/usr/bin/ksh
#
# Widden your terminal window all the way across your screen.
# It will be easier to read the script.
#
# Jump to line 190. That's about where the main script starts.
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
# USAGE: BCV-Est.sh -[B] -[F] -[M] -S servername [-C new_config_file]
#
#	Place in crontab to run with STDOUT & STDERR redirected to a
#	log file in the logs directory. i.e.:
#
#	0 2 * * 6,0 /usr/local/bin/bcvscripts/bin/BCV-Est.sh -FBWS server09 > /usr/local/bin/bcvscripts/logs/server09_BCV_LOG 2>&1
#	0 2 * * 1-5 /usr/local/bin/bcvscripts/bin/BCV-Est.sh -BWS server09 > /usr/local/bin/bcvscripts/logs/server09_BCV_LOG 2>&1
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
#	The servername MUST start with server.
#
#	Defaults are:
#		Establish in Incremental mode
#		Visual Monitor OFF
#		Backups OFF
#		Config File: /usr/local/bin/bcvscripts/etc/bcv_scripts.conf
#
#	The F, M, C, B options do not have to be used. They are optional.
#		-F = Will run a FULL Establish
#		-M = Will display information on the screen as the script
#			performs any sleep function.
#		-W = Will cause the script to wait until a preset time before
#			Splitting the BCVs.  It was designed to be used with
#			crontab since Data Services relies on the Split
#			taking place a set times.
#			The time to split is set in the Config File.
#			DON'T use it on the command line unless you have
#			properly set the time in the Config File. You could
#			end up waiting for a very long time.
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
#	As always you can combine command that do not take arguements behind
#	one dash.
#	Examples:	BCV-Est.sh -S server09
#			BCV-Est.sh -FMS server09
#			BCV-Est.sh -M -Sserver09 -C Config_File-123.Dave
#			BCV-Est.sh -FMCConfig_File-123.Dave -S server09
#			BCV-Est.sh -C Config_File-123.Dave -FM -S server09
#			BCV-Est.sh -S server09 -C Config_File-123.Dave -M
#
#
# Functions - The location of the functions are declared on the FPATH line(s).
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
#					work logic contained in the functions.
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
#			were not incorporated into the waiting time.  But them
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
#
###############################################################################
# To Do List
# 1. Set up an option (-K) to stop the script and ask for confirmation before
#	beginning the next option. This will effectively introduce a better
#	way to delay the split manually until Data Services is ready. In
#	addition to any other parts of the script you want to have wait for
#	your to give the go-ahead.
# 2. Set up an option to skip the BCV split.  It would start the establish only
# 3. Remove case statements in functions that rely on hardcoded server names.
# 4. Set up PATH Variables for all commands.
# 5. Set up Oracle Notification list for errors found in Start/Stop Hot Backup
# 6. Determine the OMNIBACK_OBJ variable from the config file. Remove the
#       assignment of the variable from this function.  There are two many
#       places to change the and make sure they are sync'ed.
#
###############################################################################
# Done
#
# 05/23/02
# 	Fix the Wait to split function to figure out how long to sleep.  Can be
#       done with a case statement with set times to sleep for certain
#       difference between the Current Time and the Split Time.
#
###############################################################################
# set -x
# set -n
umask 077
###############################################################################

##### MAIN SCRIPT

##### Declaring the path to find the functions.
FPATH=/usr/local/bin/bcvscripts/testing/lib

##### Autoload the functions as they are needed.
autoload Command_Options Declare_General_Variables Declare_VolumeGroup_Variables Declare_DeviceGroup_Variables
autoload Declare_OmniBack_Variables OOP_Functions Sleeper Time_Line Time_Counter
autoload Unmount_Filesystems DEactivate_VolumeGroups Export_VolumeGroups
autoload Establish_BCVs Monitor_BCV_Establish Verify_BCV_Sync_Started Verify_BCV_Sync_Finished
autoload Start_Oracle_HotBackup_Mode Split_BCVs Verify_BCV_Split Stop_Oracle_HotBackup_Mode
autoload Import_VolumeGroups Activate_VolumeGroups FSCK_and_Mount_Filesystems
autoload Pull_Oracle_Logs Check_LVM_Errors Notify Start_OmniBack_Job
autoload Verify_Variables Clean_Up Print_Start Print_End Determine_Split_Wait

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
Establish_BCVs			# Begin the BCV Establish operations
Verify_BCV_Sync_Started		# Make sure the Establish operation started for all DGs.
Monitor_BCV_Establish		# Monitors the Establish and continues the script once
				# all establish operations are completed.
Verify_BCV_Sync_Finished	# Verifies that all Establish operations were completed.
Split_BCVs			# Split the BCVs from the Standard Devices.
Verify_BCV_Split		# Verify the Split completed successfully for all DGs.

	##### Restore the VG and Filesystem environment to prepare for backup
#Import_VolumeGroups		# Import any VGs requiring -exact mode establish
#Activate_VolumeGroups		# Activate all VGs
#FSCK_and_Mount_Filesystems	# Run FSCK & Mount all Filesystems.
#Pull_Oracle_Logs		# Pulls a copy of the Oracle Hot Backup Logs.

Check_LVM_Errors

	##### Start the Backups
Start_OmniBack_Job		# Starts the backups once the filesystems are ready and
				# the specific tape drive is ready.

Verify_Variables		# In productions it gathers the environment into a file
				# to be used for troubleshooting.  Used for testing otherwise.
Clean_Up			# Tar up the logs, and temp files.

Print_End			# Just prints main script end messages for the log files.

Notify Final			# Emails listed staff the email report.
