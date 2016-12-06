### server start 09AM
## manually add server list in file analytics.txt under scripts folder

mkdir -p /root/serverupdownlog/
rm -rf /root/serverupdownlog/*
touch /root/serverupdownlog/analytics.log
b=`date +%k`
echo "SERVER AUTOSTART `date` " > /root/serverupdownlog/analytics.log

echo "" >> /root/serverupdownlog/analytics.log

for i in `cat /scripts/analytics.txt | awk {'print $2'}` ;
do
a=`aws ec2 describe-instance-status --instance-ids $i | grep running`; 

if [ -z "$a" ]

then

aws ec2 start-instances --instance-ids $i --output text  >> /root/serverupdownlog/analytics.log;

(echo -e "From: uptime@justbuylive.com  \nTo: infra@justbuylive.com \nMIME-Version: 1.0 \nSubject: Server Auto Start `date` \nContent-Type: text/html \n"; cat /root/serverupdownlog/analytics.log ) | /usr/sbin/sendmail -t

sleep 10;

else 
if
[ $b -gt 12 ]

then

aws ec2 stop-instances --instance-ids $i --output text  >> /root/serverupdownlog/analytics.log;

(echo -e "From: uptime@justbuylive.com  \nTo: infra@justbuylive.com \nMIME-Version: 1.0 \nSubject: Server Auto Stop `date` \nContent-Type: text/html \n"; cat /root/serverupdownlog/analytics.log ) | /usr/sbin/sendmail -t

fi
fi


done
