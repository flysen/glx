#!/bin/bash
################################################################################
#	Scriptname: postgres_backup.sh
#	
#	Description: PostgreSQL backup script. 
#	1) Do some check b4 start.
#	2) Run pg_dump.
#	3) Run Vacuum.
#	4) Run Reindex
#	5) Start FTP. 
#
#	Script location: /usr/local/bin
#
#	Last update:
#	2010-11-08 - Fredrik Lysen @ Gallerix Sverige AB
#	2011-02-04 - Fredrik LyséAdded ftp section / function the script / must run as root
#	2011-02-11 - Functionized log redirect
#		   - Added mkdir -p / create parents
#		   - Changed backup ftp file to ecs.backup
#		   - Changed FTP_PROC to FTP_WORK added var to jboss.cfg
#	2011-12-08 Fredrik Lysen
#				-Remove rem lines
################################################################################
##Read upp variables from jboss.dfg file
 . /usr/bin/ecs/jboss.cfg

LOG_PATH="/var/log"
LOG_DIR="$LOG_PATH/postgres_backup"
TODAY=`date '+%d'`
DATE=`date '+%Y%m%d'`
LOG="$LOG_DIR/backup_postgres_$TODAY.log"
HOSTNAME=$(hostname)
PROGNAME=`basename $0`
DIRNAME=`dirname $0`
BIN="/usr/bin"
BACKUP_DIR="/var/files/backup_postgres"
TMP="/tmp"

## Make sure only root can run our script 
if [ "$(id -u)" != "0" ]; then
	echo $PROGNAME at $HOSTNAME must run as root| mailx -s "$HOSTNAME - Error exec as EUID > 0 " "$MAIL"
	exit 0
fi

## Redirect to logfile
log_me() {
	exec >>$LOG
	exec 2>&1
	##Start the log
	date +"Backup script STARTED  - %e %b %Y at %H:%M:%S ---------------"
}

################################################################################
## Do some pre checks
################################################################################

pre_check() {
	##Check if logdirectory exis
	if [ ! -d $LOG_DIR ]; then
		echo "Creating directory $LOG_DIR as root with EUID=`id -u`"
		/bin/mkdir $LOG_DIR
	fi

	##Create pgpass for user root
	if [ ! -f /root/.pgpass ]; then
		echo "Missing .pgpass for root creating..."
		echo "localhost:5432:ecs:postgres:postgres" > /root/.pgpass
		/bin/chmod 0600 /root/.pgpass
	fi

	##Check if backup dir exist
	if [ ! -d $BACKUP_DIR ]; then
		echo "Creating directory structure $BACKUP_DIR as root with EUID=`id -u`"
		/bin/mkdir -p $BACKUP_DIR
		/bin/mkdir $BACKUP_DIR/work/
		/bin/mkdir $BACKUP_DIR/build/
		/bin/mkdir $BACKUP_DIR/proc/
	fi

	##Check that SITE_ID variable is set
	if [ "$SITEID" = "" ]; then
		echo "Missing SITE_ID variable in $PROGNAME at $HOSTNAME" | mailx -s "$HOSTNAME - Error SITE_ID not set" "$MAIL"
		exit 0
	fi
}

################################################################################
## Start to dump the ECS database
################################################################################

dump_database() {
	##Dump database to file
	$BIN/pg_dump -U "postgres" -h "localhost" -F c -b -v -f "$BACKUP_DIR/build/$$.bac" ecs

	##Vacuum database
	$BIN/vacuumdb --host "localhost" --dbname ecs --username "postgres" --full --analyze --verbose 2> /dev/null
	
	##Reindex database
	$BIN/reindexdb --host "localhost" --dbname ecs --username "postgres" 2> /dev/null

	##Check that dump exist and not zero
	if [ -f $BACKUP_DIR/build/$$.bac ]; then
		mv $BACKUP_DIR/build/$$.bac $BACKUP_DIR/work/ecs.backup
	else
		mailx -s "$HOSTNAME - Error backupfile $LOG" "$MAIL" < $LOG
		exit 0
	fi
}

################################################################################
## Start FTP job
################################################################################

ftp_send() {
if cd $BACKUP_DIR/work; then

	for i in `ls`; do
		ftp -nvi << EOF
		open $FTP_SERVER
		user $USERNAME $PASSWORD
		cd $FTP_BUILD
		pwd
		binary
		put $i
		ren /$FTP_BUILD/$i /$FTP_WORK/$i
		quit
EOF
        mv $i $BACKUP_DIR/proc/${SITEID}_${TODAY}.bac
    done
fi
}

## Execute functions
	pre_check
	log_me
	dump_database
	ftp_send
date +"Backup script END  - %e %b %Y at %H:%M:%S ---------------"

## Make shure to exit
exit 0