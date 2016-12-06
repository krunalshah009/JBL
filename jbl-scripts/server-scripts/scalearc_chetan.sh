#!/bin/bash
HMPATH=/graylog-scalearc
for CLSTNO in {2..5};do
#for CLSTNO in 4 5 ;do
MINUTE=$(date +%M)
rm -rf $HMPATH/cid_$CLSTNO/cid_$CLSTNO.log
if [ $MINUTE -lt 2 ];then
FILENAME=/scalearc_logs/`date +%Y%m%d`/cid_$CLSTNO/idb.log.$CLSTNO.`date --date "-1 hour" +%Y%m%d%H`
else
FILENAME=/scalearc_logs/`date +%Y%m%d`/cid_$CLSTNO/idb.log.$CLSTNO.`date +%Y%m%d%H`
fi
cd $HMPATH
./scalearc_log.awk $FILENAME >> $HMPATH/cid_$CLSTNO/cid_$CLSTNO.txt
awk -v d1="$(date --date="-10 min" "+%Y-%m-%d %H:%M"):01" -v d2="$(date --date="-1 min" "+%Y-%m-%d %H:%M"):59" '$0 > d1 && $0 < d2 || $0 ~ d2' $HMPATH/cid_$CLSTNO/cid_$CLSTNO.txt >> $HMPATH/cid_$CLSTNO/cid_$CLSTNO.log
rm -rf $HMPATH/cid_$CLSTNO/cid_$CLSTNO.txt
done
