#!/bin/sh -e
### BEGIN INIT INFO
# Provides: jboss_init
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: This will take care or stat and stop of jboss server
# Description: Script are placed in /etc/init.d, and should run as default runlevels
# eg. update-rc.d jboss_init.sh defaults.
# 1. Place the script in "/etc/init.d"
# 2. Make it executable using "chmod +x jboss_init.sh"
# 3. Add it to default runlevels, "update-rc.d jboss_init.sh defaults"
# Script are meant to be fired as user="administrator"
### END INIT INFO

# Author: Fredrik Lysén<fredrik.lysen@gallerix.com>


case "$1" in
'start')
        su administrator "-c /usr/bin/ecs/Start_JBoss.sh"
        ;;
'stop')
        su administrator "-c /usr/bin/ecs/Shutdown_JBoss.sh"
        ;;
'restart')
        su administrator "-c /usr/bin/ecs/Restart_JBoss.sh"
        ;;
*)
        echo "Usage: $0 { start | stop | restart}"
        ;;
esac
exit 0
