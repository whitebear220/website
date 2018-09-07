#!/bin/bash

############################################################################
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

############################################################################
. conf/alldeploy.conf

NODE_HOST=$1
STATE=$1

if [[ $STATE == "CT" ]]; then
    NODE_HOST=$CT_HOST
    NODE_IP=$CT_IP
else 
    NODE_HOST=$1
    NODE_IP=$2
fi

#### change /etc/hostname####
FNAME=/etc/hosts
echo "$NODE_IP      $NODE_HOST" >> $FNAME
echo "########################################################" >> log/deploy.log
echo "HOSTS = $NODE_IP $NODE_HOST"                              >> log/deploy.log
echo "HOSTS DEPLOY FINISHED"                                    >> log/deploy.log
echo "########################################################" >> log/deploy.log

# HOST_NAME=$1
# HOST_IP=$2
# # change /etc/hostname
# FNAME=${HOST_NAME:-"/etc/hosts"}
# hostname=`grep $HOST_IP /etc/hosts |grep "$HOST_NAME"`
# if [ "$hostname" = "" ] ; then
# 	sed -e "s,^127.0.1.1,#127.0.1.1,g" -i $FNAME
#     sed -e "s,^$HOST_IP,#$HOST_IP,g" -i $FNAME
#     echo "$HOST_IP $HOST_NAME" >> $FNAME
# fi