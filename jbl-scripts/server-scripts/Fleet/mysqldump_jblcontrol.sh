#!/bin/bash

#Setting up the environment


export JOBSTARTTIME=$(/bin/date "+%Y-%m-%d-%H:%M:%S")

export JOBSTARTTIMEUTC=$(/bin/date --utc "+%Y-%m-%d-%H:%M:%S-UTC")

export STDOUT=/home/milinds/scripts/logs/mysqldump_jblcontrol.out.$JOBSTARTTIME

export STDERR=/home/milinds/scripts/logs/mysqldump_jblcontrol.err.$JOBSTARTTIME

echo "Redirecting STDOUT to $STDOUT"

echo "Redirecting STDERR to $STDERR"

exec > "$STDOUT" || exit 1

exec 2> "$STDERR" || exit 1


echo "Job /home/milinds/scripts/logs/mysqldump_jblcontrol started at $JOBSTARTTIME"

echo "Job working directory $WORKDIR"


# Shell script to backup MySql database

# -------------------------------------------------------------------------

### SET variables

MailTo="milind.srivastava@justbuylive.com"

########### MySQL connection parameters ###############

DBUSER="root"

DBPASS="jbl_fleet12#$"

#DBHOST=""

#DBPORT=""

########################################################


# Linux bin paths

MYSQL="$(which mysql)"

MYSQLDUMP="/usr/bin/mysqldump"

GZIP="$(which gzip)"

########################################################

# Backup Destination directory

DEST="/home/milinds/dbbackups"

# Main directory where backup will be stored

MBD="/home/milinds/dbbackups/mysqldump"

#Main directory where for output files

DIROUT="/home/milinds/scripts/temp"

# Get data in dd-mm-yyyy format

NOW="$(date +"%d-%m-%Y")"

# File to store current backup file

FILE=""

# Store list of databases

DBS="db_fleet"


# do not backup these databases

DBS_NO="#mysql50#2016-05-21_12-20-56 jblmock sys justdat_api jbl_loadtest db_jbl information_schema justbuylivemock_11042016 justbuylivemock_alpha justbuylivemock_alpha1 justbuylivemock_alpha2 justbuylivemock_alpha3 justbuylivemock_beta justbuylivemock_beta1 justbuylivemock_beta2 justbuylivemock_beta3 justbuylivemock_beta4 justbuylivemock_beta5 justbuylivemock_beta6 justbuylivemock_beta_dv justbuylivemock_uat_old justbuytrack mysql performance_schema yourls"

### END of variable setting

########################################################

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Start of the script."

### Check if disk space is available

declare -i varspace

varspace=`df -hT | grep /dev/xvda1 | awk -F ' ' '{print $5}' | cut -c 1-2`

if [ "$varspace" -gt 30 ]; then

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

    $MYSQLDUMP -u $DBUSER -p$DBPASS --single-transaction --set-gtid-purged=OFF $db | $GZIP -9 > $FILE

    
    echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Backup Completed for $db."

    fi

done

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Logical Backup Done."

else 

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [ERROR] Disk Space not available."

fi

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Moving files to s3 bucket."

aws s3 sync /home/milinds/dbbackups/mysqldump/ s3://jbldb-backup-nv/mysqldump/fleetdb/

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Syncing to s3 bucket done."

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Removing files older than 2 days."

find /home/milinds/dbbackups/mysqldump -type f -mtime 2 -exec rm -f {} \;

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Files removed."

#### END of script.

echo "[`date +%Y\-%m\-%d\ %H\:%M\:%S`] [INFO] Script Completed!!!!!"


