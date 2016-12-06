#!/bin/bash
dt=`date "+%d%h:%H:%M"`
ht=`/bin/hostname`
/bin/awk -v d1="$(date --date="-10 min" "+%b %_d %H:%M")" -v d2="$(date "+%b %_d %H:%M")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/history.log >>/var/log/10mail
kkk=''
while read line;
do kkk="$kkk <br> $line";
done < /var/log/10mail
if [ -s /var/log/10mail  ]

then
(echo -e "From: uptime@justbuylive.com  \nTo: kunal.patil@justbuylive.com \nMIME-Version: 1.0 \nSubject: Server $ht commands history of 10 min \nContent-Type: text/html \n\n"; echo -e "$kkk") | /usr/sbin/sendmail -t
#(echo -e "From: uptime@justbuylive.com  \nTo: kunal.patil@justbuylive.com \nMIME-Version: 1.0 \nSubject: Server $ht commands run for 15 min \nContent-Type: text/html \n\n"; echo -e "$kkk") | /usr/sbin/sendmail -t
#echo $kkk;
rm -rf /var/log/10mail;
fi

