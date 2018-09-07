#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

function OPENSTACK_NORMAL()
{
    #MARIADB CLUSTER
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT USAGE ON *.* to localadmin @'%' IDENTIFIED BY 'openstack';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES on *.* to localadmin @'%';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT USAGE ON *.* to localadmin @'localhost' IDENTIFIED BY 'openstack';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES on *.* to localadmin@'localhost';"
    #KEYSTEON
    mysql -uroot -p$MARIADB_PASSWORD -e "CREATE DATABASE keystone;"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$OPENSTACK_DBPASS';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$OPENSTACK_DBPASS';"
    #GLANCE
    mysql -uroot -p$MARIADB_PASSWORD -e "CREATE DATABASE glance;"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost'  IDENTIFIED BY '$OPENSTACK_DBPASS';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$OPENSTACK_DBPASS';"
    #NOVA
    mysql -uroot -p$MARIADB_PASSWORD -e "CREATE DATABASE nova;"
    mysql -uroot -p$MARIADB_PASSWORD -e "CREATE DATABASE nova_api;"
    mysql -uroot -p$MARIADB_PASSWORD -e "CREATE DATABASE nova_cell0;"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$OPENSTACK_DBPASS';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$OPENSTACK_DBPASS';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '$OPENSTACK_DBPASS';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '$OPENSTACK_DBPASS';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '$OPENSTACK_DBPASS';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '$OPENSTACK_DBPASS';"
    #NEUTRON
    mysql -uroot -p$MARIADB_PASSWORD -e "CREATE DATABASE neutron;"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost'  IDENTIFIED BY '$OPENSTACK_DBPASS';"
    mysql -uroot -p$MARIADB_PASSWORD -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%'  IDENTIFIED BY '$OPENSTACK_DBPASS';"
}

#START
. conf/alldeploy.conf
FNAME=/etc/mysql/conf.d/openstack.cnf
INAME=file/openstack.cnf
STATE=$1

HOST_IP=`echo $MANAGE_IP | gawk -F'/' '{ print $1 }'`

#Create normal 
OPENSTACK_NORMAL

#MYSQL CNF
JNAME=file/openstack.cnf.one
cp $JNAME $FNAME
sed -e "s,%HOST_IP%,0.0.0.0,g" -i $FNAME

#SERVICE RESTART
systemctl restart mariadb.service


echo "########################################################" >> log/deploy.log
echo "MARIADB DEPLOY FINISHED"                                  >> log/deploy.log
echo "########################################################" >> log/deploy.log