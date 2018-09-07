#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
function NEUTRONCONF()
{
FNAME=/etc/neutron/neutron.conf
INAME=file/neutron.conf
cp $FNAME $FNAME.bak
cp $INAME $FNAME
sed -e "s,%HOST_IP%,$HOST_IP,g" -i $FNAME
sed -e "s,%HOST_NAME%,$CT_HOST,g" -i $FNAME
sed -e "s,%DB_HOST%,$DB_HOST,g" -i $FNAME
sed -e "s,%NEUTRON_DB%,$OPENSTACK_DBPASS,g" -i $FNAME
sed -e "s,%NOVA_DB%,$OPENSTACK_DBPASS,g" -i $FNAME
chown neutron:neutron $FNAME
chmod 644 $FNAME
}
#sed -e "s,^,,g" -i $FNAME
function ML2()
{
FNAME=/etc/neutron/plugins/ml2/ml2_conf.ini
INAME=file/ml2_conf.ini
cp $FNAME $FNAME.bak
cp $INAME $FNAME
chown neutron:neutron $FNAME
chmod 644 $FNAME
}

function BRIDGE()
{
FNAME=/etc/neutron/plugins/ml2/linuxbridge_agent.ini
INAME=file/linuxbridge_agent.ini
cp $FNAME $FNAME.bak
cp $INAME $FNAME
sed -e "s,%PUBLIC_PORT%,$PUBLIC_PORT,g" -i $FNAME
sed -e "s,%VXLAN_IP%,$VXLAN,g" -i $FNAME
chown neutron:neutron $FNAME
chmod 644 $FNAME
}

function L3 ()
{
FNAME=/etc/neutron/l3_agent.ini
INAME=file/l3_agent.ini
cp $FNAME $FNAME.bak
cp $INAME $FNAME
chown neutron:neutron $FNAME
chmod 644 $FNAME
}

function DHCP()
{
FNAME=/etc/neutron/dhcp_agent.ini
INAME=file/dhcp_agent.ini
cp $FNAME $FNAME.bak
cp $INAME $FNAME
echo 'dhcp-option-force=26,1450' | sudo tee /etc/neutron/dnsmasq-neutron.conf >> log/deploy.log
chown neutron:neutron $FNAME
chmod 644 $FNAME
}

function META()
{
FNAME=/etc/neutron/metadata_agent.ini
INAME=file/metadata_agent.ini
cp $FNAME $FNAME.bak
cp $INAME $FNAME
sed -e "s,%HOST_IP%,$HOST_IP,g" -i $FNAME
sed -e "s,%METADATA_SECRET%,$METADATA_SECRET,g" -i $FNAME
chown neutron:neutron $FNAME
chmod 644 $FNAME
}

#START

# METADATA_SECRET=$METADATA_SECRET
# PUBLIC_PORT=$PUBLIC_PORT
# OPENSTACK_DB=$OPENSTACK_DB
. conf/alldeploy.conf
STATE=$1
HOST_IP=`echo $MANAGE_IP | gawk -F'/' '{ print $1 }'`
VXLAN=`echo $VMLAN_IP | gawk -F'/' '{ print $1 }'`
HOST_IP=$HOST_IP

case ${1} in
    "CT")
        NEUTRONCONF
        ML2
        #
        /usr/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head
        #Service restart
        for i in neutron-server
        do
        systemctl stop $i.service
        systemctl start $i.service
        done
    ;;
    #NEUTRON FINISH
    "COM")
        HOST_IP=$2
        VXLAN=$3
        NEUTRONCONF
        BRIDGE
        for i in neutron-linuxbridge-agent
        do
        systemctl stop $i.service
        systemctl start $i.service
        done
    ;;
    "NET")
        NEUTRONCONF
        BRIDGE
        META
        ML2
        L3
        DHCP
        #Service restart
        for i in neutron-server neutron-linuxbridge-agent neutron-dhcp-agent neutron-metadata-agent neutron-l3-agent
        do
        systemctl stop $i.service
        systemctl start $i.service
        echo "SERVICE $i RESTART"
        done
        echo "NEUTRON FINISH DEPLOY"
        #NEUTRON FINISH DEPLOY
    ;;
    "ONE")
        NEUTRONCONF
        BRIDGE
        META
        ML2
        L3
        DHCP
        /usr/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head >> log/deploy.log 2>&1
        for i in neutron-server neutron-linuxbridge-agent neutron-dhcp-agent neutron-metadata-agent neutron-l3-agent
        do
        systemctl stop $i.service
        systemctl start $i.service
        echo "Service $i Restart"  >> log/deploy.log 2>&1
        done
    ;;
esac

sleep 5

echo "########################################################"  >> log/deploy.log 2>&1
echo "OPENSTACK NEUTRON DEPLOY FINISHED"                         >> log/deploy.log 2>&1
echo "########################################################"  >> log/deploy.log 2>&1