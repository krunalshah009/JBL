#!/bin/bash

#Setting up the environment


export JOBSTARTTIME=$(/bin/date "+%Y-%m-%d-%H:%M:%S")

export JOBSTARTTIMEUTC=$(/bin/date --utc "+%Y-%m-%d-%H:%M:%S-UTC")


export STDOUT=/home/milinds/scripts/logs/mysqlbackup_logical.out.$JOBSTARTTIME

export STDERR=/home/milinds/scripts/logs/mysqlbackup_logical.err.$JOBSTARTTIME

echo "Redirecting STDOUT to $STDOUT"

echo "Redirecting STDERR to $STDERR"

exec > "$STDOUT" || exit 1

exec 2> "$STDERR" || exit 1



echo "Job /home/milinds/scripts/logs/mysqlbackup_logical started at $JOBSTARTTIME"

echo "Job working directory $WORKDIR"


# Shell script to backup MySql database

# -------------------------------------------------------------------------

### SET variables

MailTo="milind.srivastava@justbuylive.com"

########### MySQL connection parameters ###############

DBUSER="root"

DBPASS="aH_JT-E4Tj9m9j8"

#DBHOST=""

#DBPORT=""

########################################################


# Linux bin paths

MYSQL="$(which mysql)"

MYSQLDUMP="/usr/bin/mysqldump"

GZIP="$(which gzip)"

########################################################

# Backup Destination directory

DEST="/logs/dbbackups"

# Main directory where backup will be stored

MBD="/logs/dbbackups/mysqldump"

#Main directory where for output files

DIROUT="/home/milinds/temp"

# Get data in dd-mm-yyyy format

NOW="$(date +"%d-%m-%Y")"

# File to store current backup file

FILE=""

# Store list of databases

DBS="justbuylive"


# do not backup these databases

DBS_NO="justdat_api test #mysql50#2016-05-21_12-20-56 jblmock jbl_loadtest db_jbl information_schema justbuylivemock_11042016 justbuylivemock_alpha justbuylivemock_alpha1 justbuylivemock_alpha2 justbuylivemock_alpha3 justbuylivemock_beta justbuylivemock_beta1 justbuylivemock_beta2 justbuylivemock_beta3 justbuylivemock_beta4 justbuylivemock_beta5 justbuylivemock_beta6 justbuylivemock_beta_dv justbuylivemock_uat_old justbuytrack mysql performance_schema yourls"

### END of variable setting

########################################################

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Start of the script."

### Check if disk space is available

declare -i varspace

varspace=`df -hT | grep /dev/xvdc | awk -F ' ' '{print $5}' | cut -c 1-2`

if [ "$varspace" -gt 25 ]; then

echo "Disk Space is okay. Initiating data dump."

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Disk Space Check Completed."


### Create base directory if not exists

[ ! -d $MBD ] && mkdir -p $MBD || :

# Get all database list first

echo "$INSTANCE_HOME"

DBS=`echo "SELECT schema_name FROM INFORMATION_SCHEMA.SCHEMATA order by schema_name desc" | mysql -u $DBUSER -p$DBPASS  --skip-column-names`


for db in $DBS

do

    skipdb=-1

    if [ "$DBS_NO" != "" ];

    then

    for i in $DBS_NO

    do

    [ "$db" == "$i" ] && skipdb=1 || :

    done

    fi


    if [ "$skipdb" == "-1" ] ; then

    FILE="$MBD/$db.$NOW.gz"

    echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Starting backup for $db."

    echo $FILE

    $MYSQLDUMP -u $DBUSER -p$DBPASS --ignore-table=justbuylive.arch_device_notification_status --single-transaction --set-gtid-purged=OFF --master-data=2 $db | $GZIP -9 > $FILE

    
    echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Backup Completed for $db."

    fi

done


echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Logical Backup Done."


else 

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [ERROR] Disk Space not available."

fi


echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Moving files to s3 bucket."

aws s3 sync /logs/dbbackups/mysqldump/ s3://jbldb-backup-nv/mysqldump/

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Syncing to s3 bucket done."

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Removing files older than 1 day."

find /logs/dbbackups/mysqldump -type f -mtime 1 -exec rm -f {} \;

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Files removed."

#### END of script.

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Script Completed!!!!!"

