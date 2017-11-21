#!/bin/sh  
#title           :"recent.sh - Find Recent Changes"
#description     :Find the most recently modified files in a directory and all subdirectories
#author          :Scott DeHaan
#version         :1.0    
#cron            :none
#bash_version    :GNU bash, version 3.2.25(1)-release (x86_64-redhat-linux-gnu)
#==============================================================================

find /path/to/dir -type f | perl -ne 'chomp(@files = <>); my $p = 9; foreach my $f (sort { (stat($a))[$p] <=> (stat($b))[$p] } @files) { print scalar localtime((stat($f))[$p]), "\t", $f, "\n" }' | tail