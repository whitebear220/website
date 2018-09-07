#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

## ROLE : ocata_nova.sh CT
## ROLE : ocata_nova.sh COMPUTE 10.x.x.x

function NOVA_CONF()
{
FNAME=/etc/nova/nova.conf
INAME=file/nova.conf
cp $FNAME $FNAME.bak
cp $INAME $FNAME
sed -e "s,%HOST_IP%,$HOST_IP,g" -i $FNAME
sed -e "s,%DB_HOST%,$DB_HOST,g" -i $FNAME
sed -e "s,%HOST_NAME%,$CT_HOST,g" -i $FNAME
sed -e "s,%NOVA_DB%,$OPENSTACK_DBPASS,g" -i $FNAME
sed -e "s,%NEUTRON_DB%,$OPENSTACK_DBPASS,g" -i $FNAME
sed -e "s,%METADATA_SECRET%,$METADATA_SECRET,g" -i $FNAME
sed -e "s,%PALACEMENT_DB%,$OPENSTACK_DBPASS,g" -i $FNAME

chown nova:nova $FNAME
chmod 644 $FNAME
}

#START
. conf/alldeploy.conf
STATE=$1

if [[ $STATE == "CT" ]]; then
	HOST_IP=`echo $MANAGE_IP | gawk -F'/' '{ print $1 }'`
	NOVA_CONF
	/usr/bin/nova-manage api_db sync
	# pike need chmod nova-manage.log
	chmod 777 /var/log/nova/nova-manage.log
	su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
	su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
	/usr/bin/nova-manage db sync
	nova-manage cell_v2 list_cells
	nova-manage cell_v2 simple_cell_setup
	for i in nova-api nova-consoleauth nova-scheduler nova-conductor nova-novncproxy
	do
	systemctl stop $i.service
	systemctl start $i.service
	done
elif [[ $STATE == "COMPUTE" ]]; then
	HOST_IP=`echo $2 | gawk -F'/' '{ print $1 }'`
	NOVA_CONF
	# pike need chmod nova-manage.log
	chmod 777 /var/log/nova/nova-manage.log
	su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
	systemctl stop nova-compute.service
	systemctl start nova-compute.service
elif [[ $STATE == "ONE" ]]; then
	HOST_IP=`echo $MANAGE_IP | gawk -F'/' '{ print $1 }'`
	NOVA_CONF
	/usr/bin/nova-manage api_db sync  >> log/deploy.log 2>&1
	# pike need chmod nova-manage.log
	chmod 777 /var/log/nova/nova-manage.log
	su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova  >> log/deploy.log 2>&1
	su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova  >> log/deploy.log 2>&1
	/usr/bin/nova-manage db sync  >> log/deploy.log 2>&1
	nova-manage cell_v2 list_cells  >> log/deploy.log 2>&1
	nova-manage cell_v2 simple_cell_setup  >> log/deploy.log 2>&1
	for i in nova-api nova-consoleauth nova-scheduler nova-conductor nova-novncproxy nova-compute
	do
	systemctl stop $i.service
	systemctl start $i.service
	done
	## deploy nova-compute
	openstack compute service list --service nova-compute  >> log/deploy.log 2>&1
	su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova  >> log/deploy.log 2>&1
fi
rm -f /var/lib/nova/nova.sqlite
sleep 3

echo "########################################################"  >> log/deploy.log 2>&1
echo "OPENSTACK NOVA DEPLOY FINISHED"							 >> log/deploy.log 2>&1
echo "########################################################"  >> log/deploy.log 2>&1