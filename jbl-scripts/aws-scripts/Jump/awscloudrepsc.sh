read -p "Please enter EventName : " EVNM
echo $EVNM
sleep 10
> awslog
> awscloudrep
> awscloupath
for month in  0 1 2  ;
do i=`date --date "$month month ago" +%m`
	for ((j=31;j>0;j--)) 
	do
		rm -rf awscloudrep
		echo start list for $j >> awslog
		aws s3 ls s3://jbl-trail-prod/AWSLogs/323051035076/CloudTrail/us-east-1/2016/11/$j/  | awk {'print $4'} >> awscloudrep
		if [[ -s awscloudrep ]] ; then
			echo data >> awslog
			for k in `cat awscloudrep`
			do 
				aws s3 cp s3://jbl-trail-prod/AWSLogs/323051035076/CloudTrail/us-east-1/2016/11/$j/$k . >> awslog
				echo Downloaded >> awslog
				gunzip $k >> awslog
				file=`echo $k | sed 's/.gz//g'`
				echo unzip >> awslog
				echo start to read >> awslog
				OUTPUT=`jq '.[][] | .eventName'  $file | sed 's/"//g' | grep $EVNM | uniq`
				echo OUTPUT is $OUTPUT >> awslog
				if [ "$OUTPUT" ]
				then 
					echo s3://jbl-trail-prod/AWSLogs/323051035076/CloudTrail/us-east-1/2016/11/$j/$k >> awscloupath
				fi
			echo start deletion  >> awslog
			rm -rf $file >> awslog
			done
		else 
			echo no data >> awslog
		fi
		echo ++++  >> awslog
	done
done
(echo -e "From: chetan.marathe@justbuylive.com  \nTo: chetan.marathe@justbuylive.com \nMIME-Version: 1.0 \nSubject:  cloudtrail filtered log`date` \nContent-Type: text/html \n"; cat awscloupath  ) | /usr/sbin/sendmail -t
