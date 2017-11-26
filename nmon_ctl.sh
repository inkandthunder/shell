#!/bin/ksh
##############################
# Tuneable vars

HOSTNAME=`hostname`
case "$HOSTNAME" in
  host*)  ENV=DorP   ;OS=RHEL6   ;CLUSTERED_HOSTS="hostname1 hostname2";;
esac

base_dir=/tmp/nmonctl
rem_dir=/tmp/nmondata
scripts_dir=/usr/global/app_name/nmon
dropoff=/apps/app_name/id/nmon

##############################
# Set up other variables

pids_dir=$rem_dir/pids
data_dir=$rem_dir/data

##############################

# Check usage

if [[ $# -ne 2 && $# -ne 3 ]]
then
        print "usage: $0 [start|stop] run_name (run_duration)"
        exit 1
fi

if [[ "$action" = "start"  && $# -ne 3 ]]
then
        print "usage: $0 [start|stop] run_name (run_duration)"
        exit 1
fi

if [[ "$action" = "stop"  && $# -ne 2 ]]
then
        print "usage: $0 [start|stop] run_name (run_duration)"
        exit 1
fi

action=$1
run_name=$2

if [ "$action" = "start" ]
then
        duration=$3
fi


### Check the base dirs exist. If not create them
if [ ! -d $base_dir ]
then
        mkdir $base_dir
fi

newbase=$base_dir/$run_name
if [ ! -d $newbase ]
then
        mkdir $newbase
fi

if [ ! -d $dropoff ]
then
        mkdir $dropoff
fi


if   [ $action = "start" ]
then
        for host in $CLUSTERED_HOSTS
        do
                ssh $host $scripts_dir/nmon_start.sh $run_name $duration
        done
echo 
echo "-----------------------"
echo "Please re-launch th-nmon and select Option #3 (stop) when you need to terminate this test."
echo
elif [ $action = "stop" ]
then
        for host in $CLUSTERED_HOSTS
        do
                ssh $host $scripts_dir/nmon_stop.sh $run_name
                data_file=$data_dir/${host}_${run_name}_*.nmon
#               echo "scp $host:$data_file $newbase"
                scp $host:$data_file $newbase
        done

cd $newbase
zip $dropoff/nmon_$run_name *
#zip -r $dropoff/nmon_$run_name $newbase
chmod 775 /apps/app_name/id/nmon/*

#Uncomment this if you'd like to clean up the tmp directories right away.  Otherwise, items in /tmp will walk-off over time
#rm -r $newbase

echo 
echo "-----------------------"
echo "Reports Collated Successfully. Please use nmon Analyser or Consolidator to view the data."
echo "The nmon reports are located at: $dropoff/nmon_$run_name.zip"
echo 
fi

