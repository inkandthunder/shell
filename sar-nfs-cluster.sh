#!/bin/sh
#
# rev: 1.1  swd  02/05/2013

echo
echo
echo "sar-nfs-cluster.sh v1.1 - 2/5/2014"
echo "Sysstat NFS Utility"

LOG=/dir1/dir2/logs
START_TIME=15:00:01
END_TIME=15:40:01
# Set up date/time for use with filename
NOW=$(date +"%Y-%m-%d-%H.%M.%S")
echo $NOW

# Open file descriptor 3 (fd #3) for reading with server-list.txt
exec 3< serverList.txt

# Read from fd #3 until end of file
while read SERVER <&3 ; do
    echo
    echo sarNFS start on $SERVER.
    ssh $SERVER "sar -n NFS -s ${START_TIME} -e ${END_TIME} >> ${LOG}/sarnfs_${NOW}.txt"
#   ssh $SERVER "sar -n NFS -f /var/log/sa/sa04 >> ${LOG}/sarnfs_${NOW}.txt" 
    echo sarNFS completed on $SERVER.
done

# Close input for fd #3
exec 3>&-

