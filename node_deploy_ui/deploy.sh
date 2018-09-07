#!/bin/bash

############################################################################
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

############################################################################

function CT()
{
# /bin/bash bin/sys_hosts.sh CT
# /bin/bash bin/sys_hostname.sh CT
# /bin/bash bin/sys_interfaces.sh MASTER
/bin/bash bin/openstack_ppa.sh CT
# /bin/bash bin/sys_libvirtd.sh 
/bin/bash bin/sys_ntp.sh CT
/bin/bash bin/sys_memcached.sh
/bin/bash bin/sys_rabbitmq.sh
# /bin/bash bin/sys_mariadb.sh MASTER

/bin/bash bin/openstack_keystone.sh
/bin/bash bin/openstack_glance.sh
/bin/bash bin/openstack_nova.sh CT
/bin/bash bin/openstack_neutron.sh CT
/bin/bash bin/openstack_horizon.sh

# /bin/bash openstack_adduser.sh
}

function COMPUTE()
{
# /bin/bash bin/sys_hosts.sh $1
# /bin/bash bin/sys_hostname.sh $1
# /bin/bash bin/sys_interfaces.sh MASTER
# /bin/bash bin/sys_sysctl.sh
/bin/bash bin/openstack_ppa.sh COMPUTE
/bin/bash bin/sys_libvirtd.sh 
/bin/bash bin/sys_ntp.sh OTEHER

/bin/bash bin/openstack_nova.sh COMPUTE
/bin/bash bin/openstack_neutron.sh COMPUTE
}

function NETWORK()
{
# /bin/bash bin/sys_hosts.sh $1
# /bin/bash bin/sys_hostname.sh $1
# /bin/bash bin/sys_interfaces.sh MASTER
# /bin/bash bin/sys_sysctl.sh
/bin/bash bin/openstack_ppa.sh NETWORK
/bin/bash bin/sys_ntp.sh OTEHER
/bin/bash bin/openstack_neutron.sh NETWORK
}

function ONE()
{
/bin/bash bin/sys_hosts.sh CT
/bin/bash bin/sys_hostname.sh CT
/bin/bash bin/sys_interfaces.sh ONE
/bin/bash bin/sys_sysctl.sh
/bin/bash bin/openstack_ppa.sh ONE
/bin/bash bin/sys_memcached.sh 
/bin/bash bin/sys_rabbitmq.sh
/bin/bash bin/sys_mariadb.sh
/bin/bash bin/openstack_keystone.sh
/bin/bash bin/openstack_glance.sh
/bin/bash bin/openstack_nova.sh ONE
/bin/bash bin/openstack_neutron.sh ONE
/bin/bash bin/openstack_horizon.sh
/bin/bash bin/openstack_adduser.sh
}

echo "localadmin ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/localadmin    >> log/deploy.log 2>&1
sudo chmod 0440 /etc/sudoers.d/localadmin                                           >> log/deploy.log 2>&1
. conf/alldeploy.conf
DATESTART=`date`


case ${1} in
    "CT")
        CT
    ;;
    "COMPUTE")
        
    ;;
    "NETWORK")
        
    ;;
    "ONE")
    ONE
esac



echo "DEPLOY START" >> log/deploy.log 2>&1
echo "$DATESTART" >> log/deploy.log 2>&1
echo "==========================================" >> log/deploy.log 2>&1
echo "DEPLOY FINISH"  >> log/deploy.log 2>&1
date >> log/deploy.log 2>&1
echo "==========================================" >> log/deploy.log 2>&1

