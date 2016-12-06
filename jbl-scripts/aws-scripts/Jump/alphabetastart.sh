### server start 09AM
## manually add server list in file alphabetastart.txt under scripts folderset
set +v
mkdir -p /root/serverupdownlog/
rm -rf /root/serverupdownlog/alphabetastart.log
touch /root/serverupdownlog/alphabetastart.log
b=`date +%k`
echo "SERVER AUTOSTART `date` " > /root/serverupdownlog/alphabetastart.log

echo "" >> /root/serverupdownlog/alphabetastart.log

for i in `cat /scripts/alphabetastart.txt | awk {'print $2'}` ;
do
a=`aws ec2 describe-instance-status --instance-ids $i | grep running`; 
servername=`aws ec2 describe-instances --instance-ids $i --query Reservations[].Instances[].Tags[0]  --output text`
if [ -z "$a" ]

then
	if [ $b -gt 8 ]; then

		aws ec2 start-instances --instance-ids $i --output text  >> /root/serverupdownlog/alphabetastart.log;
		(echo -e "From: uptime@justbuylive.com  \nTo: infra@justbuylive.com \nMIME-Version: 1.0 \nSubject: Server $servername Auto Start `date` \nContent-Type: text/html \n"; cat /root/serverupdownlog/alphabetastart.log ) | /usr/sbin/sendmail -t
	fi
		sleep 10;

else 
if
[ $b -lt 1 ]

then

		aws ec2 stop-instances --instance-ids $i --output text  >> /root/serverupdownlog/alphabetastart.log;
		(echo -e "From: uptime@justbuylive.com  \nTo: infra@justbuylive.com \nMIME-Version: 1.0 \nSubject: Server $servername Auto Stop `date` \nContent-Type: text/html \n"; cat /root/serverupdownlog/alphabetastart.log ) | /usr/sbin/sendmail -t
fi
fi

#(echo -e "From: uptime@justbuylive.com  \nTo: infra@justbuylive.com \nMIME-Version: 1.0 \nSubject: Server Auto Start `date` \nContent-Type: text/html \n"; cat /root/serverupdownlog/alphabetastart.log ) | /usr/sbin/sendmail -t

done

set -v
