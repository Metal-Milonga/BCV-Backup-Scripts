# BCV-Backup-Script
## BASH script to control backups of EMC Symmetrix BCVs.

This script is here for preservation mostly.  It is not intended to be used by anyone, because the technology it was used on is 10+ years old.  I doubt you would find these systems in a production environment anymore.

It is also here, because I think it is the best thing I have written to date.  Certainly, it is the biggest.

This script controlled the backup of three sets of Business Continuance Volumes (BCV) on an EMC Symmetrix storage system.  The BCV is like a 3rd mirror of the data that can be attached and detached from the mirrored pairs dynamically.  When attached, you run commands to sync them with the mirrored pairs.  Then you detach them, and mount them on another server to be backed up to (in those days) tape.  The sync'ing could be full or incremental as you wished.

In the environment I ran at the time, there were three groups of BCVs, and each one connected to a separate Oracle database.  They had to be mounted on the HP-UX servers running Oracle, and they sync'ed up with the current state of the databases.  Then they were detached, unmounted, and remounted on another HP-UX server running HP's OmniBack II backup software.  The entire process had many points in which problems could occur.

IT management, and I wanted the whole thing automated, but I would not let them hire out the process.  Since I was the main admin of the environment, I wanted it to work my way, and in a way that I could understand and fix myself.  KSH was the only thing I knew well enough to script in at that time.

There 3 databases that made use of the BCVs, and each on ran on a different HP-UX server.  The filesystems for the databases and for the BCVs were LVM based.  Backups were controlled by another HP-UX server also connected directly with the Symmetrix.  At night the BCVs would be mounted on the database servers while they were being sync'ed with the databases, then unmounted, and mounted on the backup server. This was done so that the backup process, which ran during the morning hours, and its agents did not impact the load on the database servers.  Mounting and unmounting the BCV Volume Groups needed to be done correctly according with LVM best practices, or eventually the LVM structure would get corrupted.

Along with the LVM control, proper control of the Oracle hot backup process, and the Symmetrix process of attaching, syncing, and detaching BCVs had to be performed according to the official procedures as published by the vendor.

I had several criteria for the script.

1. One script to rule them all. I wanted to be able to backup any BCV group with the same script.  I did not want to have a separate script to run for each BCV group.

2. I wanted only one configuration script to control any and all BCV backup.

3. There were 3 BCV groups at the time: I wanted to be able to run 3 instances of the script at the same time without them stepping on each other.

4. I wanted to be able to run the script automatically or interactively.

5. I wanted to make extreme use of shell script functions, in a effort to reuse code where needed, and try to make the process a bit more understandable.  Everything was to be handled by functions.

6. I wanted all of the functions to be in external files from the main script, so it would not be unbearably long.  All the main script would do is call functions.

7. I wanted the script to define it variable once using the information in the configuration file. I did NOT want to have to reinitialize variable as each function loaded which seemed necessary with functions in separate files.

8. I wanted detailed logs of every phase.

9. I wanted role-based notification.  I could get a full report, send just the necessary info to the DBAs, and error notifications to the operations guys and gals.

10. I wanted error checking on every step the script took.  Automation is great, but only after it has been tested to make sure it does not break other things while it does its assigned task.

11. strict control of the LVM, BCV, Oracle, and OmniBack processes and procedures.

I started the scripting in 2001 or 2002.  It went live in 2002.  I was in the process of writing a man page for the script when I ended up leaving that company.  I understand it ran for quite a while after I left.

It was the most intense script learning experience.  I have no idea how my script code compares to other's style or if my scripting is a mess or not.

## How to use it.

The main script is bin/BCV_Est.sh.  It is named in this mixed case to try to prevent accidental execution.  There are several commandline options built in including help to print a usage message.  In fact entering just the script with no options would execute a usage message and exit.

The main, and required, configuration file is etc/bcv_scripts.conf, and each section is, hopefully, clearly explained.

Document $Id$
