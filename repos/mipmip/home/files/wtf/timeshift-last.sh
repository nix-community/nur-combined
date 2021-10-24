#!/bin/sh
printf "Latest Mayan DB-backup:      "
ls -1t /home/pim/Sys/Mayan/DatabaseBackups|head -n1 | cut -c12- | rev| cut -c9- | rev | tr _ ' '|sed 's/-/:/3'
printf "Latest Mayan App-backup:     "
ls -1t /home/pim/Sys/Mayan/AppBackups|head -n1 | cut -c11- | rev| cut -c12- | rev | tr _ ' '|sed 's/-/:/3'
printf "Latest Timeshift SDC-backup: "
sudo timeshift --list-snapshots | tail | tr -s ' ' | cut -d ' ' -f 3 | sort | tail -n 1 | tr _ ' '|sed 's/-/:/3' | rev | cut -c4- | rev #| cat <(echo -n "Latest Timeshift backup: ") - >
printf "Latest Timeshift NFS-backup: "
TIMESTAMP=$(cat /tmp/ojs-piethein-sync-latest.json | tr -d ' ,"' |grep created | cut -d ":" -f2)
date -d @$TIMESTAMP +"%Y-%m-%d %H:%M"
echo ----
df -h | grep "timeshift\|Files\|nfs"| tr -s " " | cut -d " " -f 6,2,3,4,5| column -t

