#!/bin/ksh
PATH=$PATH:/usr/local/bin:
export PATH

##############################
# Tuneable vars

NMON_INSTALL=/usr/global/app_name/nmon
HOSTNAME=`hostname`
case "$HOSTNAME" in
  host*)  ENV=DorP   ;OS=RHEL6   ;CLUSTERED_HOSTS="hostname1 hostname2";;
esac

case $OS in
  RHEL6) nmonexe=$NMON_INSTALL/nmon_rhel6 ;;
  RHEL5) nmonexe=$NMON_INSTALL/nmon_rhel5 ;;
esac

base_dir=/tmp/nmondata
max_samples=280              # Max number of samples to be collected
min_interval=5               # The minimum intercal allowed in seconds.

##############################
# Set up other variables
min_time=0
let "min_time = max_samples * min_interval"
pids_dir=$base_dir/pids
data_dir=$base_dir/data

##############################

# Check usage

if [ $# -ne 2 ] 
then
	print "usage: $0 run_name run_duration (run_duration is in minutes)"
	exit 1
fi

run_name=$1
duration=$2
out_file=$data_dir/$(uname -n)_${run_name}_$(date +"%Y%m%d%H%M%S").nmon

### Check the base dirs exist. If not create them

if [ ! -d $base_dir ]
then
	mkdir $base_dir
fi
if [ ! -d $pids_dir ]
then
	mkdir $pids_dir
fi
if [ ! -d $data_dir ]
then
	mkdir $data_dir
fi

### check that the test is not already running

# Is there a pid file for this test ?

if [ -f $pids_dir/$run_name.pid ]
then
	# Pid file exists
	print "Test already in progress. Stop test first."
	exit 
fi

### Ok no pid file so start her up

# You have to figure out the test interval.

req_seconds=0
let "req_seconds = duration * 60"

#print "req_seconds = $req_seconds";
#print "min_time = $min_time";

# Calc the interval.

interval=$min_interval
count=0

if [ $min_time -ge $req_seconds ]
then
	let "count = $req_seconds / $interval"

else

	let "count = $req_seconds / $interval"
	while [ $count -gt $max_samples ]
	do
		let "interval = interval + 1"
		let "count = $req_seconds / $interval"
	done
fi

capture_time=0;
let "capture_time = interval * count"

print "Starting Nmon now on host $(uname -n)"
print "Samples  = $count. Interval = $interval secs. Capture Time = $capture_time secs."
#print "Output datafile = $out_file"

nmon_pid=$($nmonexe -F $out_file -t -c $count -s $interval -p | tail -1 | awk '{ print $0 }')
echo $nmon_pid > $pids_dir/$run_name.pid

print "Nmon started at $(date) process id $nmon_pid."

