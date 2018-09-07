#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

. conf/alldeploy.conf


NOVAADMIN_OPENRC=${NOVAADMIN_OPENRC:-"/home/localadmin/admin_openrc"}
DEMO_OPENRC=${DEMO_OPENRC:-"/home/localadmin/demo_openrc"}
#glance
. $NOVAADMIN_OPENRC
# wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
curl -O http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img  >> log/deploy.log 2>&1
/usr/bin/glance image-create --name "cirros-0.3.4-x86_64" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility public --progress  >> log/deploy.log 2>&1

#flavor
openstack flavor create --public small --id auto --ram 512 --disk 10 --vcpus 1  >> log/deploy.log 2>&1
openstack flavor create --public normal --id auto --ram 1024 --disk 20 --vcpus 2  >> log/deploy.log 2>&1
openstack flavor create --public large --id auto --ram 2048 --disk 30 --vcpus 4  >> log/deploy.log 2>&1

#neutron
. $NOVAADMIN_OPENRC
/usr/bin/neutron net-create ext-net --router:external --provider:physical_network external --provider:network_type flat  >> log/deploy.log 2>&1
/usr/bin/neutron subnet-create ext-net $EXT_NET --allocation-pool start=$EXT_START,end=$EXT_STOP --disable-dhcp --gateway $EXT_GATEWAY --name ext-subnet  >> log/deploy.log 2>&1
/usr/bin/neutron net-create admin-net  >> log/deploy.log 2>&1
/usr/bin/neutron subnet-create admin-net $CLIENT_NET --gateway $CLIENT_GATEWAY --dns-nameserver $EXT_DNS --name admin-subnet  >> log/deploy.log 2>&1
/usr/bin/neutron router-create admin-router  >> log/deploy.log 2>&1
/usr/bin/neutron router-interface-add admin-router admin-subnet  >> log/deploy.log 2>&1
/usr/bin/neutron router-gateway-set admin-router ext-net  >> log/deploy.log 2>&1
# . $DEMO_OPENRC
# /usr/bin/neutron net-create demo-net
# /usr/bin/neutron subnet-create demo-net $DEMO_NET --gateway $DEMO_GATEWAY --dns-nameserver $DEMO_DNS --name demo-subnet
# /usr/bin/neutron router-create demo-router
# /usr/bin/neutron router-interface-add demo-router demo-subnet
# /usr/bin/neutron router-gateway-set demo-router ext-net

