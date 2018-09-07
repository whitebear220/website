#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


#### sysctl.conf ####
FNAME=/etc/sysctl.conf
CNAME=`sysctl -p |grep "net.ipv4"`
cp $FNAME $FNAME.bak
if [[ $CNAME == "" ]]; then
echo "net.ipv4.ip_nonlocal_bind = 1" >> $FNAME
echo "net.ipv4.ip_forward = 1" >> $FNAME
echo "net.ipv4.conf.all.rp_filter = 0" >> $FNAME
echo "net.ipv4.conf.default.rp_filter = 0" >> $FNAME
echo "net.ipv6.ip_nonlocal_bind=1" >>$FNAME
echo "net.ipv6.conf.all.forwarding = 1" >> $FNAME
# echo "net.bridge.bridge-nf-call-iptables=1" >> $FNAME
# echo "net.bridge.bridge-nf-call-ip6tables=1" >> $FNAME
fi

sysctl -p >> log/deploy.log 2>&1

echo "########################################################" >> log/deploy.log
echo "STSCTL DEPLOY FINISHED"                                   >> log/deploy.log
echo "########################################################" >> log/deploy.log