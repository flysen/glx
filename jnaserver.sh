#!/bin/sh

#
# JNA-server startup script.
#
# Description: Start the local JNA-server in the directory
#  where the script is located.
#
# Script location: /bin/usr/ecs/
#                  /bin/usr/ecs/ecs-jnaserver/
#
# Last update:
#  2010-11-01, Ola Ekelund.
#

DIRNAME=`dirname $0`
PROGNAME=`basename $0`
ECS_DIR="/usr/bin/ecs"

# Set JAVA_HOME
JAVA_HOME="$ECS_DIR/jre"
JAVA="$JAVA_HOME/bin/java"

"$ECS_DIR/ecs-jnaserver/jnaclient.sh"

"$JAVA"	-Duser.language=sv -Duser.region=SE -jar jnaserver.jar

