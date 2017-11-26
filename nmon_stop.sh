#!/bin/ksh
PATH=$PATH:/usr/local/bin:
export PATH

##############################
# Tuneable vars
base_dir=/tmp/nmondata

##############################
# Set up other variables
pids_dir=$base_dir/pids
data_dir=$base_dir/data

##############################

# Check usage

if [ $# -ne 1 ]
then
        print "usage: $0 run_name"
        exit 1
fi

run_name=$1
out_file=$data_dir/$run_name.nmon
pid_file=$pids_dir/$run_name.pid

# Is there a pid file for this test ?

if [ ! -f $pid_file ]
then
        # Pid file exists
        print "Cannot find pid file [${pid_file}]. No test running"
        exit
fi

### Ok pid file so check for process

pid=$(cat $pid_file)

if [ $(ps -p $pid | grep -c nmon) -eq 1 ]
then
        print "Process identified. Terminating process"
        ps -p $pid
        kill -15 $pid
fi

rm -f $pid_file

