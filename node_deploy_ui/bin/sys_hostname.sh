#!/bin/bash

############################################################################
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
. conf/alldeploy.conf
STATE=$1

if [[ $STATE == "CT" ]];then
    HOSTNAME_FNAME=$CT_HOST
else
    HOSTNAME_FNAME=$1
fi

# change /etc/hosts and hostname
FNAME=/etc/hostname
echo "$HOSTNAME_FNAME" > $FNAME
/bin/hostname -F $FNAME
echo "########################################################"  >> log/deploy.log
echo "HOSTNAME = $HOSTNAME_FNAME"                                >> log/deploy.log
echo "HOSTNAME DEPLOY FINISHED"                                  >> log/deploy.log
echo "########################################################"  >> log/deploy.log

