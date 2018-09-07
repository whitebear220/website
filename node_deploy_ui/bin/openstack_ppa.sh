#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

function INSTALL()
{
    apt install -y $1 >> log/deploy.log 2>&1
}
function SERVICESTOP()
{
    systemctl stop $1.service >> log/deploy.log 2>&1
}

function INIT()
{
    for i in ntp python-openstackclient rabbitmq-server memcached mariadb-client python-mysqldb
    do 
        INSTALL $i
    done

    SERVICESTOP memcached
}

function DB()
{
    echo "mysql-server-5.5 mysql-server/root_password password $MARIADB_PASSWORD" | debconf-set-selections
    echo "mysql-server-5.5 mysql-server/root_password_again password $MARIADB_PASSWORD" | debconf-set-selections
    echo "mysql-server-5.5 mysql-server/start_on_boot boolean true" | debconf-set-selections
    INSTALL mariadb-server
}

function KEYSTONE()
{
    echo "manual" | sudo tee /etc/init/keystone.override >> log/deploy.log
    for i in keystone apache2 libapache2-mod-wsgi
    do
        INSTALL $i
    done
}

function GLANCE()
{
    INSTALL glance
    SERVICESTOP glance-api
    SERVICESTOP  glance-registry
}

function NOVA_CT()
{
    for i in nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler nova-placement-api
    do
        INSTALL $i
        SERVICESTOP $i
    done
}

function NOVA_COM()
{
    INSTALL nova-compute
}

function NEUTRON_CT()
{
    INSTALL neutron-server
    INSTALL neutron-plugin-ml2
}

function NEUTRON_NET()
{
    for i in neutron-plugin-ml2 neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent  neutron-linuxbridge-agent
    do
        INSTALL $i
    done
}

function NEUTRON_COM()
{
    INSTALL neutron-linuxbridge-agent
}

function HORIZON()
{
    INSTALL openstack-dashboard
}

function CINDER_CT()
{
    INSTALL cinder-api
    INSTALL cinder-scheduler
}

function CINDER_VOL()
{
    INSTALL cinder-volume 
    INSTALL lvm2
}

function REPOSITORY()
{
    #upgrade openstack source
    INSTALL software-properties-common
    add-apt-repository -y cloud-archive:$OPENSTACK_VER >> log/deploy.log 2>&1
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 >> log/deploy.log 2>&1
    add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu xenial main' >> log/deploy.log 2>&1
    apt -y update >> log/deploy.log 2>&1
    # dpkg --configure -a
    apt -y dist-upgrade >> log/deploy.log 2>&1
}

####START#####
. conf/alldeploy.conf
# MARIADB_PASSWORD="openstack"

REPOSITORY

case ${1} in
    "CT")
        INIT
        DB
        KEYSTONE
        GLANCE
        NOVA_CT
        NEUTRON_CT
        HORIZON
    ;;
    "COM")
        NOVA_COM
        NEUTRON_COM
    ;;
    "NET")
        NEUTRON_NET
    ;;
    "ONE")
        INIT
        DB
        KEYSTONE
        GLANCE
        NOVA_CT
        NOVA_COM
        NEUTRON_CT
        NEUTRON_NET
        HORIZON
    ;;
esac
echo "########################################################" >> log/deploy.log
echo "OPENSTACK PPA INSTALL FINISHED"                           >> log/deploy.log
echo "########################################################" >> log/deploy.log
