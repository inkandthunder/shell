#!/bin/sh
#title           :"Nmon Launcher"
#description     :This script will collect nmon stastics for a specific period or allow user to run performance analyser interactively.
#author          :Scott DHaan
#date            :20150323
#version         :2.0 version 2017 
#cron            :none
#notes           :
#bash_version    :GNU bash, version 3.2.25(1)-release (x86_64-redhat-linux-gnu)
#==============================================================================

#--Initialize global variables------------------------------------------------#

NOW=$(date +"%Y-%m-%d-%H.%M.%S")
SCRIPT_NAME=nmon
SCRIPT_OWNER="Scott DeHaan"
ID=app_id
ID_HOME=/export/home/$ID
ID_LOG=$ID_HOME/local/logs/$ID/$SCRIPT_NAME.log
ID_SCRIPTS=/usr/global/app_id/scripts
CASEDATE=$(date +"%Y%m%d-%H%M%S")

# Resolve to app_id environment based on hostname
HOSTNAME=`hostname`
case "$HOSTNAME" in
  host*)  ENV=DorP   ;OS=RHEL6   ;CLUSTERED_HOSTS="hostname1 hostname2";;
esac

# Tunable variables for nmon
NMON_INSTALL=/usr/global/app_id/nmon
NMON_BASE=/tmp/nmondata
NMON_PID=$NMON_BASE/pids
NMON_DATA=$NMON_BASE/data
NMON_JOB=$NMON_BASE/job
max_samples=280              # Max number of samples to be collected
min_interval=5               # The minimum intercal allowed in seconds.
OUT_FILE=$NMON_DATA/$(uname -n)_${run_name}_$CASEDATE.nmon
PID_FILE=$NMON_PID/$run_name.pid

# Which version of nmon to run
case $OS in
  RHEL6) nmonexe=$NMON_INSTALL/nmon_rhel6 ;;
  RHEL5) nmonexe=$NMON_INSTALL/nmon_rhel5 ;;
esac

# Quiet Mode Variables
#action=$1
#run_name=$2


#--Run------------------------------------------------------------------------#
#
# This will run an instance of the nmon executable interactively
# (after determining what OS/Version of nmon is to be used).
#
#-----------------------------------------------------------------------------#

function nmonrun
{
$nmonexe
}

#--Collect--------------------------------------------------------------------#
#
# This function will run nmon in quiet mode on all servers in a TH cluster and 
# save the output to a zip that can be imported in the analyzer/consolidator.
#
#-----------------------------------------------------------------------------#

function collect
{

#Collect Run Name information
echo ""
read -p "Please type a unique name for this collection (Tip: Don't use spaces or periods): " run_name
read -p "Please define a duration (in minutes) for the collection period: " duration
confirm_collect
}

function confirm_collect
{
echo ""
echo "Test Name:                    $run_name"
echo "Test Duration (in minutes):   $duration"

  while true; do
    read -p "Is the information you entered correct? (y/n): " collect_yn
    case $collect_yn in
        [Yy]* ) echo "Test starting at $NOW";
                $NMON_INSTALL/nmon_ctl.sh start $run_name $duration
                exit;;
        [Nn]* ) collect;;
        * ) echo "Invalid entry. Please answer (y)es or (n)o.";;
    esac
done

}

function stop_collect
{
cd $NMON_PID

if [ ! -f $NMON_PID/*.pid ]; then
    echo "No tests are currently running on this system"
    exit
else
echo "Select the test that you'd like to stop."
select FILENAME in *;
do
newvar=${FILENAME%.*}

     echo "You selected "$newvar". This test will now be terminated."

$NMON_INSTALL/nmon_ctl.sh stop $newvar
exit
done
fi

}


#--FTP------------------------------------------------------------------------#
#
# This will prompt the user if they would like the output sent directly
# to the vendor FTP
#
#-----------------------------------------------------------------------------#

function ftp
{
echo
echo "Work in progress - Coming Soon!"
echo
exit
}

#--Help-----------------------------------------------------------------------#

function help
{
echo
echo "Work in progress"
echo
exit
}

#--Main Menu------------------------------------------------------------------#

 function mainmenu
 {
    opt=""
    while [ "$opt" != "x" ]
    do
        clear
        echo "nmon v1.0"
        echo "Nmon Performance Monitor for Linux"
        echo
        echo Choose from the following selections.
        echo
        echo "1. livemode       -->  Run nmon in 'Live Mode' to view current performance"
        echo "2. collect        -->  Start collecting nmon data for use in Consolidator/Analyser"
        echo "3. stop           -->  Stop collecting nmon data and compile results"
        echo "4. ftp            -->  Send nmon data to External Vendor"
        echo "5. help           -->  Help Menu"
        echo "0. exit           -->  Exit Program"
        echo
        read -p "Select option [1-5] or 0, then hit Enter to continue: " opt
        if [ "$opt" = "1" ]; then
             nmonrun
        elif [ "$opt" = "2" ]; then
             collect
        elif [ "$opt" = "3" ]; then
             stop_collect
        elif [ "$opt" = "4" ]; then
             ftp
        elif [ "$opt" = "5" ]; then
             help
        elif [ "$opt" = "0" ];then
             break
        fi
   done
}

#if [ "$action" = "start" ]
#then
#quiet_test
#fi

mainmenu
