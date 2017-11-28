#!/bin/sh  
#title           :"JBoss Log Management Utility - jboss-logs v2.1"
#description     :Bundles JVM logs from across a JBoss cluster, with optional ability to auto-send to outside vendor.
#author          :Scott DeHaan
#date            :20140923
#version         :2.1    
#cron            :none
#notes           :If this code works, it was written by Scott DeHaan.  If not, I don't know who wrote it.
#bash_version    :GNU bash, version 3.2.25(1)-release (x86_64-redhat-linux-gnu)
#==============================================================================

#--Initialize global variables------------------------------------------------#

NOW=$(date +"%Y-%m-%d-%H.%M.%S")
SCRIPT_NAME=jboss-logs
SCRIPT_OWNER=""
ID=`whoami`
APP=/apps/app_name
TEMP=$APP/tmp
JVM_LOG=$APP/logs
ID_HOME=/export/home/$ID
SCRIPT_LOG=$ID_HOME/local/logs/$ID/$SCRIPT_NAME.log
SCRIPT_DIR=/usr/global/app_name/scripts
CASEDATE=$(date +"%Y%m%d-%H%M%S")

# Resolve to app_name environment based on hostname
HOSTNAME=`hostname`

# Optional case statement to gather logs based on cluster or lifecycle
case "$HOSTNAME" in
  host*)  ENV=DorP   ;LOG=/apps/app_name/JBoss-5.1.0/server/app_name/log/   ;JVM=( "hostname1" "hostname2" ) ;;
esac


#--Grab-----------------------------------------------------------------------#
#
# This will bundle all current app_name server, debug, and stdout log files 
# into a single zip file on the NAS mount of the cluster
#
#-----------------------------------------------------------------------------#

function grab
{

#Remove if you don't want any custom formatting of the zip file
while true; do
    read -p "Are you gathering logs for an issue that has a app_name Support Case associated with it? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Enter the 5-digit number associated with the support case: ";
		read app_case_number;
			len=${#app_case_number}
			if (( len == 5 || len == 5 ))
			then
                		read -p "You entered $app_case_number. Is this correct? (y/n): " yn
                        		case $yn in
                                		[Yy]* ) ZIPDIR="Case${app_case_number}_${ENV}_${CASEDATE}"; grab_exec; exit;;
                                		[Nn]* ) grab;;
                        		esac
			else
    				echo "That's not a correct support case format" 
				echo ""
				grab
			fi 
		exit;;
        [Nn]* ) ZIPDIR="${ENV}_logs_${CASEDATE}"; grab_exec; exit;;
        * ) echo "Invalid entry. Please answer (y)es or (n)o.";;
    esac
done
 }

function grab_exec
{
mkdir $TEMP/$ZIPDIR
for i in ${JVM[@]}; do ssh ${i} "tar --exclude="ARCHIVE" -zcvf $TEMP/$ZIPDIR/${i}_logs_$NOW.tar.gz $LOG"; done
zip -r $JVM_LOG/$ZIPDIR $TEMP/$ZIPDIR/
rm -r $TEMP/$ZIPDIR
echo "$NOW: grab executed from $HOSTNAME (Filename:$JVM_LOG/$ZIPDIR.zip)" >> $SCRIPT_LOG
echo
echo "Completed Successfully."
echo "The logs for $ENV have been placed in: $JVM_LOG/$ZIPDIR.zip"
}

#--GrabDate-------------------------------------------------------------------#
#
# This will bundle app_name server, debug, and stdout log files that have
# been archived into a .gzip/timestamped location
#
#-----------------------------------------------------------------------------#

function grabdate
 {

  DATE0=$(date +%Y-%m-%d -d "10 days ago")
  DATE9=$(date +%Y-%m-%d -d "9 days ago")
  DATE8=$(date +%Y-%m-%d -d "8 days ago")
  DATE7=$(date +%Y-%m-%d -d "7 days ago")
  DATE6=$(date +%Y-%m-%d -d "6 days ago")
  DATE5=$(date +%Y-%m-%d -d "5 days ago")
  DATE4=$(date +%Y-%m-%d -d "4 days ago")
  DATE3=$(date +%Y-%m-%d -d "3 days ago")
  DATE2=$(date +%Y-%m-%d -d "2 day ago")
  DATE1=$(date +%Y-%m-%d -d "1 days ago")

    nat=""
    while [ "$nat" != "x" ]
    do
#        clear
        
#        echo
        echo "Choose from the following history of log files. Or don't. I don't care."
        echo
        echo "1. $DATE1    -->  Yesterday"
        echo "2. $DATE2    -->  2 Days Ago"
        echo "3. $DATE3    -->  3 Days Ago"
        echo "4. $DATE4    -->  4 Days Ago"
        echo "5. $DATE5    -->  5 Days Ago"
        echo "6. $DATE6    -->  6 Days Ago"
		echo "7. $DATE7	 -->  7 Days Ago"
		echo "8. $DATE8	 -->  8 Days Ago"
		echo "9. $DATE9	 -->  9 Days Ago"
		echo "0. $DATE0	 -->  10 Days Ago"
        echo
        read -p "Options [1-0]?: " nat
        if [ "$nat" = "1" ]; then
             SDATE=$DATE1; grabdate_case
        elif [ "$nat" = "2" ]; then
             SDATE=$DATE2; grabdate_case
        elif [ "$nat" = "3" ]; then
             SDATE=$DATE3; grabdate_case
        elif [ "$nat" = "4" ]; then
             SDATE=$DATE4; grabdate_case
        elif [ "$nat" = "5" ]; then
             SDATE=$DATE5; grabdate_case
		elif [ "$nat" = "6" ]; then
             SDATE=$DATE6; grabdate_case
		elif [ "$nat" = "7" ]; then
             SDATE=$DATE7; grabdate_case
		elif [ "$nat" = "8" ]; then
             SDATE=$DATE8; grabdate_case
		elif [ "$nat" = "9" ]; then
             SDATE=$DATE9; grabdate_case
        elif [ "$nat" = "0" ];then
             SDATE=$DATE0; grabdate_case
        fi
   done    
 }

function grabdate_case
{

while true; do
    read -p "Are you gathering logs for an issue that has a app_name Support Case associated with it? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Enter the 5-digit number associated with the support case: ";
                read app_case_number;
                        len=${#app_case_number}
                        if (( len == 5 || len == 5 ))
                        then
                                read -p "You entered $app_case_number. Is this correct? (y/n): " yn
                                        case $yn in
                                                [Yy]* ) ZIPDIR="Case${app_case_number}_${ENV}_${SDATE}"; grabdate_exec; exit;;
                                                [Nn]* ) grabdate_case;;
                                        esac
                        else
                                echo "That's not a correct support case format"
                                echo ""
                                grabdate_case
                        fi
                exit;;
        [Nn]* ) ZIPDIR="${ENV}_logs_${SDATE}"; grabdate_exec; exit;;
        * ) echo "Invalid entry. Please answer (y)es or (n)o.";;
    esac
done
 }

function grabdate_exec
{
mkdir $TEMP/$ZIPDIR
for i in ${JVM[@]}; do ssh ${i} "tar -zcvf $TEMP/$ZIPDIR/${i}_logs_$SDATE.tar.gz $LOG/ARCHIVE/$SDATE"; done
FTPFILE=$JVM_LOG/$ZIPDIR
zip -r $FTPFILE $TEMP/$ZIPDIR/
rm -r $TEMP/$ZIPDIR
echo "$NOW: grabdate executed from $HOSTNAME (Filename:$JVM_LOG/$ZIPDIR.zip)" >> $SCRIPT_LOG
echo
echo "Completed Successfully."
echo "The logs for $ENV from $SDATE have been placed in: $FTPFILE.zip"
echo
read -p "Press ENTER to continue."
app_ftp_yn
}

#--FTP------------------------------------------------------------------------#
#
# Sends selected file to app_name FTP server for the vendor's analysis.
#
#-----------------------------------------------------------------------------#

 function app_ftp_yn
 {
  while true; do
    read -p "Would you like to send $FTPFILE.zip to app_name Support? (y/n): " ftp_yn
    case $ftp_yn in
        [Yy]* ) echo "Enter the 5-digit number associated with the support case: ";
                read app_case_number;
                        len=${#app_case_number}
                        if (( len == 5 || len == 5 ))
                        then
                                read -p "You entered $app_case_number. Is this correct? (y/n): " yn
                                        case $yn in
                                                [Yy]* ) ftp_function_goes_here;;
                                                [Nn]* ) grabdate_case;;
                                        esac
                        else
                                echo "That's not a correct support case format"
                                echo ""
                                grab
                        fi
                exit;;
        [Nn]* ) exit;;
        * ) echo "Invalid entry. Please answer (y)es or (n)o.";;
    esac
done
 }


#--TailLogs-------------------------------------------------------------------#
#
# Starts monitoring the STDOUT log for app_name to view current system activity.
#
#-----------------------------------------------------------------------------#

 function tail_log
 {
     while [ "tail_log" != "x" ]
     do
        tail -f $LOG/app_name_stdout.log
     done
 }

 function tail_debug
 {
     while [ "tail_debug" != "x" ]
     do
        tail -f $LOG/debug.log
     done
 }

#--Usage----------------------------------------------------------------------#

function Usage
  {
  local sn=$SCRIPT_NAME
  cat <<__EndOfUsage__|more


  usage:         $SCRIPT_NAME  [<action>]  [target] [voff] [verbose]
  purpose:       Bundles a copy of all current and past (up to 10 day history) of JVM, 
		 debug, and stdout log files.  This will also assist with moving a copy 
		 to vendor's FTP site for issue analysis if needed.
 
  action         -->  [grab|grabdate|ftp|tail|info|help]
  target         -->  [<jvm>|all|Select_JBoss_*]

  grab           -->  Bundles all current (today's) JBoss log files
  grabdate       -->  Bundles all JVM logs from any date within the past 10 days
  ftp    	 -->  Sends a log bundle to the vendor's FTP location
  tail           -->  Monitors the current stdout log file for current system output
  info           -->  Display logs file location
  help		 -->  This help message

  Examples...

__EndOfUsage__

exit
  } 


#--Main Menu------------------------------------------------------------------#

 function mainmenu
 {
    opt=""
    while [ "$opt" != "x" ]
    do
        clear
	echo "jboss-logs v2.0 - 09/22/2014"
	echo "JBoss 4.2.3 Log Management and ViENVer Utility"
	echo
	echo Choose from the following selection:
	echo 
        echo "1. grab		-->  Bundle today's JBoss logs"
        echo "2. grabdate	-->  Bundle logs from a previous day (10 day history)"
        echo "3. ftp		-->  FTP logs to External Vendor"
        echo "4. tail		-->  ViENV/Tail Current JBoss logs"
        echo "5. debug      -->  ViENV Debug/Trace File"
        echo "6. help		-->  Help Menu"
		echo "0. exit		-->  Exit Program"
	echo
        read -p "Options [1-5] or 0?: " opt
        if [ "$opt" = "1" ]; then
             grab
        elif [ "$opt" = "2" ]; then
             grabdate
        elif [ "$opt" = "3" ]; then
             app_ftp
        elif [ "$opt" = "4" ]; then
             tail_log
        elif [ "$opt" = "5" ]; then
             tail_debug
	elif [ "$opt" = "6" ]; then
             doge     
        elif [ "$opt" = "0" ];then
             break
        fi
   done
}

mainmenu

