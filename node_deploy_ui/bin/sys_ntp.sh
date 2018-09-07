#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

. conf/alldeploy.conf
DIR=/home/localadmin
FNAME=/etc/ntp.conf
cp $FNAME $FNAME.bak
cp $DIR/file/ntp.conf $FNAME
# CONTROL_HA="10.0.1.1"
STATE=$1
# CT_IP=$CT_IP
CT_NET=`ipcalc $MANAGE_IP_A | grep Network | awk '{print $2}'`
CT_MASK=`ipcalc $MANAGE_IP_A | grep Netmask | awk '{print $2}'`

if [[ $STATE = "CT" ]]; then
    echo "restrict $CT_NET mask $CT_MASK nomodify notrap" >> $FNAME
    echo "server 2.tw.pool.ntp.org" >> $FNAME
    echo "server 3.asia.pool.ntp.org" >> $FNAME
    echo "server 0.asia.pool.ntp.org" >> $FNAME
else
    echo "server $CT_IP" >> $FNAME
fi

systemctl restart ntp.service

echo "########################################################" >> log/deploy.log
echo "NTP DEPLOY FINISHED"                                      >> log/deploy.log
echo "########################################################" >> log/deploy.log
