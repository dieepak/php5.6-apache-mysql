#!/bin/bash

if [ "$PHP_DEBUG" == 1 ]
then
  # if XDEBUG_HOST is manually set
  HOST="$XDEBUG_HOST"

  # else if check if is Docker for Mac
  if [ -z "$HOST" ]; then
      HOST=`getent hosts docker.for.mac.localhost | awk '{ print $1 }'`
  fi

  # else get host ip
  if [ -z "$HOST" ]; then
      HOST=`/sbin/ip route|awk '/default/ { print $3 }'`
  fi
  
  # xdebug config
  if [ -f /etc/php/7.2/mods-available/xdebug.ini ]
  then
      sed -i "s/xdebug\.remote_host \=.*/xdebug\.remote_host\=$HOST/g" /etc/php/7.2/mods-available/xdebug.ini
  fi

fi

exec $@

source /etc/apache2/envvars
#tail -F /var/log/apache2/* &
exec apache2 -D FOREGROUND