##xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

###Script : mysqlxtrabackup.sh

#!/bin/sh

#set -x

#Executing the environment script.

export JOBSTARTTIME=$(/bin/date "+%Y-%m-%d-%H:%M:%S")

export JOBSTARTTIMEUTC=$(/bin/date --utc "+%Y-%m-%d-%H:%M:%S-UTC")


export STDOUT=/home/milinds/scripts/logs/mysqlbackup_xtrabackup.out.$JOBSTARTTIME

export STDERR=/home/milinds/scripts/logs/mysqlbackup_xtrabackup.err.$JOBSTARTTIME

echo "Redirecting STDOUT to $STDOUT"

echo "Redirecting STDERR to $STDERR"

exec > "$STDOUT" || exit 1

exec 2> "$STDERR" || exit 1



echo "Job /home/milind/scripts/logs/mysqlbackup_xtrabackup started at $JOBSTARTTIME"

# The usage of this script.

usage="Usage is $0"

usage="$usage [-b <backup_dir>]"

# Use the getopt utility to set up the command line flags.

#if [ $# == 0 ];then

 # echo "Invalid script invocation"

  #echo $usage

 # exit 1

#fi

set -- `/usr/bin/getopt b: $*`

# Process individual command line arguments

while [ $1 != -- ]; do

  case $1 in

    -b)  backup_dir=$2

         shift

         ;;

    esac

  shift

done

if [ "$backup_dir" == "" ];then

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO:] No backup directory passed. Starting full backup."

#Making a directory with current date.

datedir=`date +"%Y%m%d"`

backupdir=/logs/dbbackups/xtrabackup

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Starting full backup."

innobackupex --user=root --password=aH_JT-E4Tj9m9j8  --compress $backupdir/$datedir --slave-info --no-timestamp

if [ $? -eq 0 ]; then

   cd $backupdir

   lastfolder=`ls -lrt |tail -1|awk '{print $9}'`

   cd $lastfolder/

   from_lsn=`grep -E 'from_lsn' xtrabackup_checkpoints`

   to_lsn=`grep -E 'to_lsn' xtrabackup_checkpoints`

   last_lsn=`grep -E 'last_lsn' xtrabackup_checkpoints`

   echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Full backup completed. From_lsn=$from_lsn,To_lsn=$to_lsn and Last_lsn=$last_lsn."

   echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Backup Completed. Backup Directory :$backupdir/$datedir ."

   echo "Full Backup Complete on 172.16.11.168 Type:Physical, Utility:innobackupex." | mailx -s "Full Backup Completed Successfully on 172.16.11.168:3306" "milind.srivastava@justbuylive.com" "dba@justbuylive.com"
   
   echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Syncing on s3 bucket."

  aws s3 sync /logs/dbbackups/xtrabackup/ s3://jbldb-backup-nv/fullbackup/

  echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Syncing done."

  echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Removing files older than 2 days."

  find /logs/dbbackups/xtrabackup/*  -mtime 1 -exec rm -rf {} \;

  echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] 1 day old files removed."

   exit 1

else

   echo " [`date +%Y\-%m\-%d\ %H\:%M\:%S`] [ERROR] Backup Failed (in if condition). Please check."

fi

else

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO:] Starting backup. Backup directory:$backup_dir"

innobackupex --defaults-file=$INSTANCE_HOME/my.cnf --compress $backup_dir/$datedir --slave-info --no-timestamp

if [ $? -eq 0 ]; then

cd $backup_dir/meta

start_lsn=`grep -E 'start_lsn' backup_variables.txt`

end_lsn=`grep -E 'end_lsn' backup_variables.txt`

 echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Full backup completed.Start_lsn=$start_lsn and End_lsn=$end_lsn."

 echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Backup Completed. Backup Directory :$backup_dir ."

 echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO:] Backup Completed."

 echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Syncing on s3 bucket."

 aws s3 sync /logs/dbbackups/xtrabackup/ s3://jbldb-backup-nv/fullbackup/

 echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Syncing done."

 echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Removing files older than 2 days."

 find /logs/dbbackups/xtrabackup/*  -mtime 1 -exec rm -rf {} \;

 echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] 1 day old files removed."


exit 1

else

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [ERROR] Backup Failed (in else condition). Please check."

fi

fi

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO:] Script Completed."

#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
