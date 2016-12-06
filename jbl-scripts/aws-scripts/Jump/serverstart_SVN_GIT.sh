### server start 07AM
## manually add server list in file svn_git_start_stop.txt under scripts folder

mkdir -p /root/serverupdownlog/
rm -rf /root/serverupdownlog/svn_git_start_stop.log
touch /root/serverupdownlog/svn_git_start_stop.log
b=`date +%k`
echo "SERVER AUTOSTART `date` " > /root/serverupdownlog/svn_git_start_stop.log

echo "" >> /root/serverupdownlog/svn_git_start_stop.log

for i in `cat /scripts/svn_git_start_stop.txt | awk {'print $2'}` ;
do
a=`aws ec2 describe-instance-status --instance-ids $i | grep running`;
servername=`aws ec2 describe-instances --instance-ids $i --query Reservations[].Instances[].Tags[0]  --output text`
if [ -z "$a" ]

then
	if [ $b -gt 5 ]; then

        aws ec2 start-instances --instance-ids $i --output text  >> /root/serverupdownlog/svn_git_start_stop.log;
	(echo -e "From: uptime@justbuylive.com  \nTo: infra@justbuylive.com \nMIME-Version: 1.0 \nSubject: Server $servername Auto Start `date` \nContent-Type: text/html \n"; cat /root/serverupdownlog/svn_git_start_stop.log ) | /usr/sbin/sendmail -t
	fi
	sleep 10;

else
if
[ $b -lt 1 ]

then

aws ec2 stop-instances --instance-ids $i --output text  >> /root/serverupdownlog/svn_git_start_stop.log;
(echo -e "From: uptime@justbuylive.com  \nTo: infra@justbuylive.com \nMIME-Version: 1.0 \nSubject: Server $servername Auto Stop `date` \nContent-Type: text/html \n"; cat /root/serverupdownlog/svn_git_start_stop.log ) | /usr/sbin/sendmail -t

fi
fi

done
