#!/bin/sh  
#title           :"du-hrf.sh"
#description     :Sort du output in Human-readable format
#author          :Scott DeHaan
#version         :1.0    
#cron            :none
#notes           :echo -e prints G for Gigabytes, M for Megabytes and K for Kilobytes in a line each; 2>/dev/null send stderr to /dev/null; sort -rn sorts in reverse numerical order. Largest first
#bash_version    :GNU bash, version 3.2.25(1)-release (x86_64-redhat-linux-gnu)
#==============================================================================

for i in $(echo -e 'G\nM\nK'); do du -hsx /* 2>/dev/null | grep '[0-9]'$i | sort -rn; done
