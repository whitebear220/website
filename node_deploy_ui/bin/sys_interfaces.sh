#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

DIR=/home/localadmin
FNAME=/etc/network/interfaces
#Install ipcalc
/usr/bin/dpkg -iRE $DIR/packege/ipcalc_0.41-5_all.deb >> log/deploy.log 2>&1

# Fuction
function interfaces_net()
{
    HOST_PORT=$1
    HOST_IP=$2
    HOST_GW=$3
    HOST_DNS=$4
    ADDRESS=`ipcalc $HOST_IP | grep Address | awk '{print $2}'` 
    NETMASK=`ipcalc $HOST_IP | grep Netmask | awk '{print $2}'`
    NETWORK=`ipcalc $HOST_IP | grep Network | awk '{print $2}' | gawk -F'/' '{ print $1 }'`
    BROADCAST=`ipcalc $HOST_IP | grep Broadcast | awk '{print $2}'`

    echo "auto $HOST_PORT" >> $FNAME
    echo "iface $HOST_PORT inet static" >> $FNAME
    echo "     address $ADDRESS" >> $FNAME
    echo "     netmask $NETMASK" >> $FNAME
    echo "     network $NETWORK" >> $FNAME
    echo "     broadcast $BROADCAST" >> $FNAME
    if [[ $HOST_PORT == "$MANAGE_PORT" ]]; then
        echo "     gateway $HOST_GW" >> $FNAME
        echo "     dns-nameservers $HOST_DNS" >> $FNAME
    fi
}

function interface_lo()
{
    echo "# The loopback network interface" >> $FNAME
    echo "auto lo" >> $FNAME
    echo "iface lo inet loopback" >> $FNAME
}

function interface_updevice()
{
    HOST_PORT=$1
    echo "auto $HOST_PORT" >> $FNAME
    echo "iface $HOST_PORT inet manual" >> $FNAME
    echo "     up ip link set dev $HOST_PORT up" >> $FNAME
    # echo "     down ip link set dev $HOST_PORT down" >> $FNAME
}
# Config Formate
# MANAGE_PORT = "eth0"
# VMLAN_PORT="eth1"
# PUBLIC_PORT="eth2"
# STORAGE_PORT="eth3"
# MANAGE_IP_A = "192.168.0.1/24" 
# MANAGE_IP_B = "192.168.0.1/24" 
# MANAGE_GW = "192.168.1.1"
# VMLAN_IP_A = "192.168.1.1/24" 
# VMLAN_IP_B = "192.168.1.1/24" 
# STORAGE_IP_A = "192.168.2.1/24" 
# STORAGE_IP_B = "192.168.2.1/24" 
# DNS = 8.8.8.8
. conf/alldeploy.conf
cp $FNAME $FNAME.bak
echo "" > $FNAME
NULL=""
STATE=$1

if [[ $STATE == "MASTER" ]]; then
    MANAGEIP=$MANAGE_IP_A
    VMLANIP=$VMLAN_IP_A
    STORAGEIP=$STORAGE_IP_A
elif [[ $STATE == "BACKUP" ]]; then
    MANAGEIP=$MANAGE_IP_B
    VMLANIP=$VMLAN_IP_B
    STORAGEIP=$STORAGE_IP_B
elif [[ $STATE == "OTHER" ]]; then
    MANAGEIP=$2
    VMLANIP=$3
    STORAGEIP=$4
elif [[ $STATE == "ONE" ]]; then
    MANAGEIP=$MANAGE_IP
    VMLANIP=$VMLAN_IP
    STORAGEIP=$STORAGE_IP
fi

interface_lo

#Config Manage Network A
interfaces_net $MANAGE_PORT $MANAGEIP $MANAGE_GW $DNS

#Config VmLan Network A
interfaces_net $VMLAN_PORT $VMLANIP

#Config Storage Network A
if [[ $STORAGE_PORT ]]; then
    interfaces_net $STORAGE_PORT $STORAGEIP
fi
#Config Public Network
if [[ $MANAGE_PORT != $PUBLIC_PORT ]]; then
    interface_updevice $PUBLIC_PORT
fi

systemctl restart networking.service >> log/deploy.log 2>&1

echo "########################################################" >> log/deploy.log 2>&1
ip a s                                                          >> log/deploy.log 2>&1
echo "NETWORK DEPLOY FINISHED"                                  >> log/deploy.log 2>&1
echo "########################################################" >> log/deploy.log 2>&1