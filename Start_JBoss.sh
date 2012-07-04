#!/bin/bash
######################################################################################
# JBoss startup script.
#
# Description: Starts JBoss as a background process. These actions are performed:
#  1) Check if JBoss is already running.
#  2) Check for updates on the local server.
#  3) Start JBoss by calling the run.sh script in JBOSS_HOME. 
#
# Script location: /bin/usr/ecs/
#
# Last update:
#  2010-11-01, Ola Ekelund.
#	2010-11-09	Fredrik Lysen @ Gallerix Sverige AB
#				-Check postgres running
#				-Redirect nohup
#				-Check PID assigned (while)
######################################################################################

DIRNAME=`dirname $0`
PROGNAME=`basename $0`
ECS_DIR="/usr/bin/ecs"
ECS_LOG="$ECS_DIR/ecs-jboss/server/default/log"
PIDFILE="$ECS_DIR/ecs.pid"
LOG_DIR="/var/log"
COUNT="0"
EMAIL_ADD="fredrik.lysen@gallerix.se"

##Set JAVA_HOME
JAVA_HOME="$ECS_DIR/jre"
JAVA="$JAVA_HOME/bin/java"

##Set JBOSS_HOME
JBOSS_DIR="$ECS_DIR/ecs-jboss"
JBOSS_HOME="$JBOSS_DIR/bin"

##Check if Postgresql running
STATUS_POSTGRES=`/etc/init.d/postgresql-8.4 status|awk '{print $3}'`

##Check if JBoss is running
PID=`ps -eo pid,comm,command|grep jboss|awk '$2 == "java" {print $1}'`

##Check Postgres status
if [ -z "$STATUS_POSTGRES" ]; then
	tail -50 $LOG_DIR/postgresql/postgresql-8.4-main.log | mailx -s "$HOSTNAME $PROGNAME - Error in Postgresql" "$EMAIL_ADD"
	echo "* Postgres not running. Mail sent to $EMAIL_ADD"
	exit 0
fi

##Check if PID for jboss exist 
if [ -z "$PID" ]; then
	echo "* Starting JBoss."   

	##Check for updates
	if cd "$ECS_DIR"; then
		"$JAVA" -Djava.ext.dirs=. -Djava.security.policy=jnaclient.policy -Djna.server=http://localhost:8888 -Djna.appl=ecs-jboss -jar jnaclient.jar -v -UNIX_CLIENT
	fi
	
	##Start server
	if cd "$JBOSS_HOME"; then
		nohup ./run.sh > /dev/null 2>&1 &
	fi
	
	##Assign variable PID (if exist) 
	PID=`ps -eo pid,comm,command | grep jboss | awk '$2 == "java" { print $1 }'`
	
	##Wait for PID to be assigned
	while [ -z $PID ]; do
		COUNT=$(( $COUNT + 1 ))
		sleep 1
		##Try to assign PID again
		PID=`ps -eo pid,comm,command | grep jboss | awk '$2 == "java" { print $1 }'`
		
		##If PID not assigned whithin 10 sec die
		if [ "$COUNT" -gt 10 ]; then
			tail -100 $ECS_LOG/server.log | mailx -s "$HOSTNAME $PROGNAME - Error count over 10" "$EMAIL_ADD"
			echo "* Jboss not starting no PID assigned. Mail sent to $EMAIL_ADD"
			exit 0
		fi
	done
else
	tail -100 $ECS_LOG/server.log | mailx -s "$HOSTNAME $PROGNAME - JBoss is already running (PID $PID)" "$EMAIL_ADD" 
	echo "* JBoss is already running (PID=$PID). Mail sent to $EMAIL_ADD"
	exit 0
fi
