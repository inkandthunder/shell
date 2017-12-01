#!/bin/sh  
#title           :"Thunderhead Purge Batch Job Utility - purgejobs.sh v0.5"
#description     :This script will purge batches and spools older than a specified number of days from the Thunderhead Job Management Console.
#author          :Scott DeHaan
#date            :20140912
#version         :0.5     
#cron            :00 2 * * * /usr/global/app_name/scripts/th-purge-jobs.sh
#notes           :If this code works, it was written by Scott DeHaan.  If not, I don't know who wrote it.
#bash_version    :GNU bash, version 3.2.25(1)-release (x86_64-redhat-linux-gnu)
#==============================================================================

# Define Variables. Change these if you need to make changes.
PROCESS='java'                                                 	   # JVM Process to check for availability
HOSTNAME=`hostname`                                            
case "$HOSTNAME" in
  host1*)  LIFECYCLE=dv  ;;
  host2*)  LIFECYCLE=qa  ;;
  host3*)  LIFECYCLE=pu  ;;
esac
TH_CMD=/apps/app_name/thunderhead/$LIFECYCLE/servers/thserver/bin/ # Location of thcommand shell script
DAYS=14                                                        	   # Number of days to keep batch jobs in the system
STDOUT=/home/id/local/logs/id/th-purge.log                         # Location of logs for stdout
STDERR=/home/id/local/logs/id/th-purge_err.log                     # Location of logs for stderr
temp_email=/tmp/th-purge.temp                                      # Location of stderr for notification
NOW=$(date +"%Y-%m-%d-%H.%M.%S")                                   # Date/time for use in notification
SUBJECT="[Purge] JMC Cleanup Status on $HOSTNAME"                  # Include '[Purge]' for filtering if desired
EMAIL="name@something.com"                                         # Mailboxes and/or persons to be notified of errors (separate by comma)
FROM="me@website.com"

if pgrep -f $PROCESS >/dev/null
  then
    cd $TH_CMD
    ./thcommand.sh purgejobs $DAYS | tail -n +11 2> $STDERR >> $STDOUT 
  else
    echo "Purgejobs.sh could not run at $NOW because $PROCESS process (Thunderhead JVM) was in a stopped state." > $temp_email
    cd $TH_CMD
    ./thcommand.sh isalive >> $temp_email
    echo >> $temp_email
    echo "Please investigate the status of the JVM running on $HOSTNAME" >> $temp_email
    /bin/mail -s "$SUBJECT" "$EMAIL" -c "$FROM" < "$temp_email"
    exit
fi
 
# This code is to notify someone when this doesn't work.
if [ `ls -l $STDERR | awk '{print $5}'` -eq 0 ]
then
    echo "Purge Successful."
else
    echo "th-purge-jobs.sh may have experienced an issue at $NOW because of the following error:" > $temp_email
    cat $STDERR >> $temp_email
    echo >> $temp_email
    echo "Please check the Job Management Console and application logs on $HOSTNAME for any unusual results." >> $temp_email
    /bin/mail -s "$SUBJECT" "$EMAIL" -c "$FROM" < "$temp_email"
    exit
fi

[ -f $temp_email ] && rm $temp_email || echo ""
  exit 0
#  A zero return value from the script upon exit indicates success
#+ to the shell.
