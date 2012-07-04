#!/bin/bash
######################################################################################
#
# JBoss shutdown script.
#
# Description: Performs JBoss shutdown by following these actions:
#  1) Check if JBoss is already running.
#  2) Shut down JBoss by calling shutdown.sh in JBOSS_HOME.
#
# Location: /bin/usr/ecs/
#
# Last update:
#	2010-11-01, Ola Ekelund.
#	2010-11-05	Fredrik Lysen @ Gallerix Sverige AB
#	2010-11-09	Fredrik Lysen @ Gallerix Sverige AB
#				-Added wait shutdown to ensure reboot script working.
#				-Added (exit code 2) if failed closing jboss
######################################################################################

DIRNAME=`dirname $0`
PROGNAME=`basename $0`
ECS_DIR="/usr/bin/ecs"
ECS_LOG="$ECS_DIR/ecs-jboss/server/default/log"
PIDFILE="$ECS_DIR/ecs.pid"
COUNT="0"
EMAIL_ADD="fredrik.lysen@gallerix.se"
##Set JAVA_HOME
JAVA_HOME="$ECS_DIR/jre"
JAVA="$JAVA_HOME/bin/java"

##Check if JBoss is running
PID=`ps -eo pid,comm,command | grep jboss | awk '$2 == "java" { print $1 }'`

##PID is empty - Jboss is not running.
if [ -z "$PID" ]; then
	##Jboss has closed OK (exit with 0)
	exit 0
fi

##PID is NOT empty - Jboss is RUNNING.	
if [ ! -z "$PID" ]; then	
	if cd "$ECS_DIR/ecs-jboss/bin/"; then
		echo "* Shutting down JBoss."
		./shutdown.sh -S
		
   		##Wait until jboss closed		
   		PID=`ps -eo pid,comm,command | grep jboss | awk '$2 == "java" { print $1 }'`
   			
   		##While PID exist sleep until count done (20 sec).
   			while [ ! -z $PID ]; do
   				COUNT=$(( $COUNT + 1 ))
   				##Check PID again
   				PID=`ps -eo pid,comm,command | grep jboss | awk '$2 == "java" { print $1 }'`
   				sleep 1
   				if [ "$COUNT" -gt 20 ]; then
   					tail -100 $ECS_LOG/server.log | mailx -s "$HOSTNAME $PROGNAME - Error count over 20" "$EMAIL_ADD"
					echo "* Jboss is not closing correct. Mail sent to $EMAIL_ADD"
					##Jboss is not closed correctly (exit with 2)
					exit 2
				fi
   			done
   		##Jboss has closed OK (exit with 0)
   		exit 0
	fi
fi


##Jboss has closed OK (exit with 0)
exit 0