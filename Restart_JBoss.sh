#!/bin/bash
######################################################################################
# Restart JBoss.
#
# Description: Stop and start JBoss.
#
# Script location: /bin/usr/ecs/
#
# Last update:
#  2010-11-01, Ola Ekelund.
#	2010-11-09 	Fredrik Lysén @ Gallerix Sverige AB
#				-Change from ./sh to ./bash
#				-New counter
#				-Some check added
#######################################################################################

DIRNAME=`dirname $0`
PROGNAME=`basename $0`
ECS_DIR="/usr/bin/ecs"
ECS_LOG="$ECS_DIR/ecs-jboss/server/default/log"

## Timeout delay
DELAY="60"
COUNT="0"

## Shut down JBoss
if cd "$ECS_DIR"; then
	$ECS_DIR/Shutdown_JBoss.sh
fi

##Jboss is CLOSED $?=0
##Jboss is NOT closed correct $?=2 ;Dont have to take care of that
if [ $? = 0 ]; then
	if cd "$ECS_DIR"; then
		$ECS_DIR/Start_JBoss.sh
	fi
fi
exit 0