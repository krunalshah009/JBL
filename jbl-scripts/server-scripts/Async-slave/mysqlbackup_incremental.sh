###Script : mysqlBinlogbackup.sh
#!/bin/sh

#Executing the environment script.

export JOBSTARTTIME=$(/bin/date "+%Y-%m-%d-%H:%M:%S")

export JOBSTARTTIMEUTC=$(/bin/date --utc "+%Y-%m-%d-%H:%M:%S-UTC")

export STDOUT=/home/milinds/scripts/logs/mysqlbackup_incremental.out.$JOBSTARTTIME

export STDERR=/home/milinds/scripts/logs/mysqlbackup_incremental.err.$JOBSTARTTIME


echo "Redirecting STDOUT to $STDOUT"

echo "Redirecting STDERR to $STDERR"


exec > "$STDOUT" || exit 1

exec 2> "$STDERR" || exit 1


echo "Job /home/milinds/scripts/jobs/mysqlbackup_incremental.sh started at $JOBSTARTTIME"

### Setting the folder paths

binlogdir=/logs/

bindir=/logs/dbbackups/incremental

datedir=`date +"%Y%m%d"`

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO:] Finding files created within 15 mins."

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO:] Finding the current binlog file"

currentbinfile=`more /logs/binlog.index | cut -d'/' -f 3 | tail -1`

echo $currentbinfile

rsync /logs/$currentbinfile /logs/dbbackups/incremental/

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] Syncing on s3 bucket."

aws s3 sync /logs/dbbackups/incremental/ s3://jbldb-backup-nv/incremental/

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] Sync Complete."

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Removing files older than 1 day."

find /logs/dbbackups/incremental -type f -mtime +1 -exec rm -f {} \;

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Files removed."
echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] Script Completed."
