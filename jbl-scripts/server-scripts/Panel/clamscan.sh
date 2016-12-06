##Installation of CLAMSCAN command##

CLAMSCANCMD=`which clamscan`

        if [ -z "$CLAMSCANCMD" ];
        then
                yum -y install clamav
                echo "clamscan Command Installed Successfully"
        fi


##Installation of Sendmail command##

SENDMAILCMD=`which sendmail`

 if [ -z "$SENDMAILCMD" ];
        then
                yum -y install sendmail
                echo "sendmail Command Installed Successfully"
        fi

############### 

MAINDIR=/root/clam-scan-project
DIR=$MAINDIR/http-status-code
OUTPUT=$MAINDIR/default-db-summary.log
FINALRESULT=$MAINDIR/clam-scan-result.log

rm -rf $MAINDIR/*.log
rm -rf $DIR/*.log
rm -rf /root/clam-scan-project/http-status-code/*.txt
rm -f $MAINDIR/current.txt
mv -f $MAINDIR/host.txt $MAINDIR/current.txt
rm -f $MAINDIR/hosts.txt
rm -f $MAINDIR/add-domains.txt


	if [ ! -d "$MAINDIR" ];
	then
	   mkdir --parents $DIR
	elif [ ! -d "$DIR" ];
        then
           mkdir $DIR
        else
           rm -rf $MAINDIR/*.log
           rm -rf $DIR/*.txt
        fi

##Creation of Malware domains file##

file=/root/clam-scan-project/current.txt


	if [ -f $file ];
	then
		wget -O /root/clam-scan-project/hosts.txt http://www.malwaredomainlist.com/hostslist/hosts.txt
		cat /root/clam-scan-project/hosts.txt | col -b | grep -i '^#'>> /root/clam-scan-project/host.txt
		diff -I '^#' /root/clam-scan-project/current.txt /root/clam-scan-project/host.txt | grep "^>" | grep -v localhost | awk '{ print $3 }'  >> /root/clam-scan-project/add-domains.txt


			if [ -s /root/clam-scan-project/add-domains.txt ];
               		then
				for i in $(cat /root/clam-scan-project/add-domains.txt)
				do
        	                       x=$(echo $i | sigtool --hex-dump | sed 's/\(.*\)../\1/')
                	               echo "$i:0:*:$x" >> /root/clam-scan-project/signatures.ndb
	                        done
        	       fi
	else
		wget -O /root/clam-scan-project/hosts.txt http://www.malwaredomainlist.com/hostslist/hosts.txt
		cat /root/clam-scan-project/hosts.txt | col -b | grep -i '^#' >> /root/clam-scan-project/host.txt

				for i in $(cat /root/clam-scan-project/host.txt | grep -v "^#" | awk '{ print $2 }' | grep -v localhost)
				do
					x=$(echo $i | sigtool --hex-dump | sed 's/\(.*\)../\1/')
					echo "$i:0:*:$x" >> /root/clam-scan-project/signatures.ndb
				done
	fi


echo "<br>" >> $OUTPUT
echo "<b><i>Clam-Scan Result using Default DB</i></b>" >> $OUTPUT
echo "<br>" >> $OUTPUT
echo "<br>" >> $OUTPUT
echo "<i>Updating Clam AV database</i>" >> $OUTPUT
echo "<br>" >> $OUTPUT
echo '<pre>' >> $OUTPUT
# freshclam --no-warnings >> $OUTPUT
echo '</pre>' >> $OUTPUT
echo "<br>" >> $OUTPUT
echo "<br>" >> $OUTPUT
echo "<font color="red">" >> $OUTPUT
echo '<pre>' >> $OUTPUT
clamscan -ir /var/www/* --log $OUTPUT
echo '</pre>' >> $OUTPUT
echo "</font>" >> $OUTPUT
echo "<br>" >> $OUTPUT
sed -n "/SCAN \SUMMARY/,/Time:/p" $OUTPUT > /root/clam-scan-project/summary.log
sed -i "/SCAN \SUMMARY/,/Time:/d" $OUTPUT
echo "<b>" >> $OUTPUT
echo '<pre>' >> $OUTPUT
cat /root/clam-scan-project/summary.log >> $OUTPUT
echo '</pre>' >> $OUTPUT
echo "</b>" >> $OUTPUT
echo "<br>" >> $OUTPUT
echo "<HR ALIGN="LEFT" SIZE="3" WIDTH="70%" NOSHADE>" >> $OUTPUT
echo "<br>" >> /root/clam-scan-project/custom-db-summary.log
echo "<b><i>Clam-Scan Result using Custom DB</i></b>" >> /root/clam-scan-project/custom-db-summary.log
echo "<br>" >> /root/clam-scan-project/custom-db-summary.log
echo "<font color="red">" >> /root/clam-scan-project/custom-db-summary.log
echo '<pre>' >> /root/clam-scan-project/custom-db-summary.log
clamscan -d /root/clam-scan-project/signatures.ndb -ir /var/www/* --log /root/clam-scan-project/custom-db-summary.log
echo '</pre>' >> /root/clam-scan-project/custom-db-summary.log
echo "</font>" >> /root/clam-scan-project/custom-db-summary.log
echo "<br>" >> /root/clam-scan-project/custom-db-summary.log
sed -n "/SCAN \SUMMARY/,/Time:/p" /root/clam-scan-project/custom-db-summary.log > /root/clam-scan-project/summary.log
sed -i "/SCAN \SUMMARY/,/Time:/d" /root/clam-scan-project/custom-db-summary.log
echo "<b>" >> /root/clam-scan-project/custom-db-summary.log
echo '<pre>' >> /root/clam-scan-project/custom-db-summary.log
cat /root/clam-scan-project/summary.log >> /root/clam-scan-project/custom-db-summary.log
echo '</pre>' >> /root/clam-scan-project/custom-db-summary.log
echo "</b>" >> /root/clam-scan-project/custom-db-summary.log
cat $OUTPUT /root/clam-scan-project/custom-db-summary.log >> $FINALRESULT
sleep 100
END=`date +%H:%M`
echo "<center><b>Clam-Scan Ended: $END</b></center>" >> $FINALRESULT
echo "<br>" >> $FINALRESULT


#HOSTNAME=`echo $HOSTNAME`
(echo -e "From: clam-scan@justbuylive.com \nTo: krunal@justbuylive.com, infra@justbuylive.com \nMIME-Version: 1.0 \nSubject: Clam-Scan on $HOSTNAME  \nContent-Type: text/html \n"; cat $FINALRESULT ) | /usr/sbin/sendmail -t
