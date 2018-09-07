#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

FNAME=/etc/memcached.conf
sed -e "s,^-l 127.0.0.1,-l 0.0.0.0,g" -i $FNAME

systemctl restart memcached.service

echo "########################################################" >> log/deploy.log
echo "MEMCASHED DEPLOY FINISHED"                                >> log/deploy.log
echo "########################################################" >> log/deploy.log