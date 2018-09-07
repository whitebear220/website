#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

function KEYSTONE_MANAGE()
{
/usr/bin/keystone-manage db_sync  >> log/deploy.log 2>&1
/usr/bin/keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone  >> log/deploy.log 2>&1
/usr/bin/keystone-manage credential_setup --keystone-user keystone --keystone-group keystone  >> log/deploy.log 2>&1
/usr/bin/keystone-manage bootstrap --bootstrap-username novaadmin --bootstrap-password openstack --bootstrap-admin-url http://$HOST_NAME:35357/v3/ --bootstrap-internal-url http://$HOST_NAME:35357/v3/ --bootstrap-public-url http://$HOST_NAME:5000/v3/ --bootstrap-region-id RegionOne  >> log/deploy.log 2>&1
}

function KEYSTONE_DEMO()
{
export OS_USERNAME=novaadmin
export OS_PASSWORD=openstack
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://$HOST_NAME:35357/v3
export OS_IDENTITY_API_VERSION=3

/usr/bin/openstack project create --domain default --description "Service Project" service  >> log/deploy.log 2>&1
/usr/bin/openstack role create user  >> log/deploy.log 2>&1

# #Create admin account by admin
# /usr/bin/openstack domain create --description "Default Domain" default

# # Create demo account by user
# /usr/bin/openstack project create --domain default --description "Demo Project" demo
# /usr/bin/openstack user create --domain default --password openstack demo
# /usr/bin/openstack role add --project demo --user demo user

unset OS_URL
}

function GLANCE_USER()
{
# Create Glance user
/usr/bin/openstack user create --domain default --password openstack --email glance@example.com glance  >> log/deploy.log 2>&1
/usr/bin/openstack role add --project service --user glance admin  >> log/deploy.log 2>&1
/usr/bin/openstack service create --name glance --description "OpenStack Image service" image  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne image public http://$HOST_NAME:9292  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne image internal http://$HOST_NAME:9292  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne image admin http://$HOST_NAME:9292  >> log/deploy.log 2>&1
}

function NOVA_USER()
{
# Create Nova user
/usr/bin/openstack user create --domain default --password openstack --email nova@example.com nova  >> log/deploy.log 2>&1
/usr/bin/openstack role add --project service --user nova admin  >> log/deploy.log 2>&1
/usr/bin/openstack service create --name nova --description "OpenStack Compute" compute  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne compute public http://$HOST_NAME:8774/v2.1/%\(tenant_id\)s  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne compute internal http://$HOST_NAME:8774/v2.1/%\(tenant_id\)s  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne compute admin http://$HOST_NAME:8774/v2.1/%\(tenant_id\)s  >> log/deploy.log 2>&1

/usr/bin/openstack user create --domain default --password openstack --email placement@example.com placement  >> log/deploy.log 2>&1
/usr/bin/openstack role add --project service --user placement admin  >> log/deploy.log 2>&1
/usr/bin/openstack service create --name placement --description "OpenStack Placement" placement  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne placement public http://$HOST_NAME:8778  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne placement internal http://$HOST_NAME:8778  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne placement admin http://$HOST_NAME:8778  >> log/deploy.log 2>&1
}

function NEUTRON_USER()
{
# Create Neutron user
/usr/bin/openstack user create --domain default --password openstack --email neutron@example.com neutron  >> log/deploy.log 2>&1
/usr/bin/openstack role add --project service --user neutron admin  >> log/deploy.log 2>&1
/usr/bin/openstack service create --name neutron --description "OpenStack Networking" network  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne network public http://$HOST_NAME:9696  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne network internal http://$HOST_NAME:9696  >> log/deploy.log 2>&1
/usr/bin/openstack endpoint create --region RegionOne network admin http://$HOST_NAME:9696  >> log/deploy.log 2>&1
}

function NOVAADMIN()
{
FNAME=$1
echo "export OS_PROJECT_DOMAIN_NAME=default" > $FNAME
echo "export OS_USER_DOMAIN_NAME=default" >> $FNAME
echo "export OS_PROJECT_NAME=admin" >> $FNAME
echo "export OS_USERNAME=novaadmin" >> $FNAME
echo "export OS_PASSWORD=openstack" >> $FNAME
echo "export OS_AUTH_URL=http://$HOST_NAME:35357/v3" >> $FNAME
echo "export OS_IDENTITY_API_VERSION=3" >> $FNAME
echo "export OS_IMAGE_API_VERSION=2" >> $FNAME
}

function DEMO()
{
FNAME=$1
echo "export OS_PROJECT_DOMAIN_NAME=default" > $FNAME
echo "export OS_USER_DOMAIN_NAME=default" >> $FNAME
echo "export OS_PROJECT_NAME=demo" >> $FNAME
echo "export OS_USERNAME=demo" >> $FNAME
echo "export OS_PASSWORD=openstack" >> $FNAME
echo "export OS_AUTH_URL=http://$HOST_NAME:5000/v3" >> $FNAME
echo "export OS_IDENTITY_API_VERSION=3" >> $FNAME
echo "export OS_IMAGE_API_VERSION=2" >> $FNAME
}
# START

. conf/alldeploy.conf
HOST_NAME=$CT_HOST
STATE=$1
KESTONE_DB=$OPENSTACK_DBPASS

FNAME=/etc/keystone/keystone.conf
INAME=file/keystone.conf
JNAME=/etc/apache2/sites-available/keystone.conf
KNAME=file/keystone.conf.apache2
cp $INAME $FNAME
cp $KNAME $JNAME
chown keystone:keystone $FNAME
chmod 644 $FNAME 

# Keystone config
sed -e "s,%DB_HOST%,$DB_HOST,g" -i $FNAME
sed -e "s,%KESTONE_DB%,$KESTONE_DB,g" -i $FNAME

# apache2 config
echo "ServerName $HOST_NAME " >> /etc/apache2/apache2.conf
# ln -s /etc/apache2/sites-available/keystone.conf /etc/apache2/sites-enabled
# systemctl stop apache2.service
# systemctl start apache2.service
# sleep 5

KEYSTONE_MANAGE
systemctl stop apache2.service
systemctl start apache2.service

sleep 10

# curl http://$HOST_NAME:5000/v3
# if [[ $? == "0" ]];then
# curl http://$HOST_NAME:5000/v3 >> log/deploy.log 2>&1
KEYSTONE_DEMO
#
# DEMO_OPENRC=/home/localadmin/demo_openrc
NOVAADMIN_OPENRC=/home/localadmin/admin_openrc
# DEMO $DEMO_OPENRC
NOVAADMIN $NOVAADMIN_OPENRC
#
. $NOVAADMIN_OPENRC
GLANCE_USER
NOVA_USER
NEUTRON_USER
	# KEYSTONE FINISH	
# else
#    	#KEYSTONE NOT WORK
#    	exit 1
# 	echo "[KEYSTONE FAIL] to curl http://$HOST_NAME:5000/v3"
# fi


echo "########################################################" >> log/deploy.log 2>&1
echo "OPENSTACK KEYSTONE DEPLOY FINISHED" 						>> log/deploy.log 2>&1
echo "########################################################" >> log/deploy.log 2>&1



# case ${1} in
# 	"cinder")
# 		CINDER_USER
# 	;;
# 	"heat")
# 		HEAT_USER
#     ;;
# 	"aodh")
#     	AODH_USER
# 	;;
#     "trove")
#     	TROVE_USER
# 	;;
#     "magnum")
# 	    MAGNUM_USER
# 	;;
#     "murano")
#     	MURANO_USER
# 	;;
#     "barbican")
#     	BARBICAN_USER
# 	;;
#     "ceilometer")
#     	CEILOMETER_USER
# 	;;
#     "swift")
#     	SWIFT_USER
# 	;;
#     "manila")
#     	MANILA_USER
# 	;;
# esac


