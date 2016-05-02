# BCV-Backup-Script
BASH script to control backups of EMC Symmetrix BCVs.

This script is here for preservation mostly.  It is not intended to be used by anyone, because the technology it was used on is 10+ years old.  I doubt you would find these systems in a production environment anymore.

It is also here, because I think it is the best thing I have written to date.  Certainly, it is the biggest.

This script controlled the backup of three sets of Business Continuance Volumes on an EMC Symmetrix storage system.  The BCV is like a 3rd mirror of the data that can be attached and detached from the mirrored pairs dynamically.  When attached, you run commands to sync them with the mirrored pairs.  Then you detach them, and mount them on another server to be backed up to (in those days) tape.  The sync'ing could be full or incremental as you wished.

In the environment I ran at the time, there were three groups of BCVs, and each one connected to a separate Oracle database.  They had to be mounted on the HP-UX servers running Oracle, and they sync'ed up with the current state of the databases.  Then they were detached, unmounted, and remounted on another HP-UX server running HP's OmniBack II backup software.  The entire process had many points in which problems could occur.

IT management, and I wanted the whole thing scripted, but I would not let them hire out the process.  Since I was the main admin of the environment, I wanted it to work my way, in a way that I could understand and fix myself.  KSH was the only thing I knew well enough to script in, and my team as well.

I had several criteria for the script.

1. One script to rule them all. I wanted to be able to backup any BCV group with the same script.  I did not want to have a separate script to run for each BCV group.

2. I wanted only one configuration script to control any and all BCV backup.

3. There were 3 BCV groups at the time: I wanted to be able to run 3 instances of the script at the same time without them stepping on each other.

4. I wanted to be able to run the script automatically or interactively.

5. I wanted detailed logs of every phase.

6. I wanted role-based notification.  I could get a full report, but send just the necessary info to the DBAs.

7. I wanted to make extreme use of shell script functions, in a effort to reuse code where needed, and try to make the process a bit more understandable.

8. I wanted error checking on every step the script took.  Automation is great, but only after it has been tested to make sure it does not break other things while it does its assigned task.

I started the scripting in 2001 or 2002.  It went live in 2002.  I was in the process of writing a man page for the script when I ended up leaving that company.  I understand it ran for quite a while after I left.

It was the most intense script learning experience.  I have no idea how my script code compares to other's style or if my scripting is a mess or not.
