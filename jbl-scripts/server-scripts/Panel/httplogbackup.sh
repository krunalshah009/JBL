#!/bin/bash
IP=`/sbin/ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{ print $1}'`

DT=`date +%Y%m%d --date="1 days ago"`

ls -lrt /var/log/httpd/ | grep -i $DT | awk {'print $9'} > /var/log/httpd/loglist.txt
for i in $(cat /var/log/httpd/loglist.txt);
do
aws s3 cp /var/log/httpd/$i s3://nv-httpd-logs-backup/$IP/$DT/ 
done
