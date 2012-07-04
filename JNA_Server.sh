#!/bin/sh

#
# JNA-server startup script.
#
# Description: Updates the local JNA-server resources and start
#  the local JNA-server.
#  1) Performe check for updates at the remote JNA-server.
#  2) If newer files exists at the remote JNA-server these are downloaded.
#  3) Start the local JNA-server.
#
# Script location: /bin/usr/ecs/
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

# Update this JNA archive
"$JAVA" -Djava.ext.dirs=. -Djava.security.policy=jnaclient.policy -Djna.server=http://192.168.1.29:8889 -Djna.appl=ecs-jnaserver -Duser.language=sv -Duser.region=SE -jar jnaclient.jar -v -UNIX_CLIENT

# Start local JNA-server
if cd "$ECS_DIR/ecs-jnaserver"; then
	./jnaserver.sh
fi

