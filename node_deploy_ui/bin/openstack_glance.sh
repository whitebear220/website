#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Glance-api config
function GLANCE_API()
{
FNAME=/etc/glance/glance-api.conf
INAME=file/glance-api.conf
cp $FNAME $FNAME.bak
cp $INAME $FNAME
sed -e "s,%HOST_IP%,$HOST_IP,g" -i $FNAME
sed -e "s,%HOST_NAME%,$CT_HOST,g" -i $FNAME
sed -e "s,%DB_HOST%,$DB_HOST,g" -i $FNAME
sed -e "s,%GLANCE_DB%,$OPENSTACK_DBPASS,g" -i $FNAME
chown glance:glance $FNAME
chmod 644 $FNAME
}

# Glance-registry config
function GLANCE_REGISTRY()
{
FNAME=/etc/glance/glance-registry.conf
INAME=file/glance-registry.conf
cp $FNAME $FNAME.bak
cp $INAME $FNAME
sed -e "s,%HOST_IP%,$HOST_IP,g" -i $FNAME
sed -e "s,%HOST_NAME%,$CT_HOST,g" -i $FNAME
sed -e "s,%DB_HOST%,$DB_HOST,g" -i $FNAME
sed -e "s,%GLANCE_DB%,$OPENSTACK_DBPASS,g" -i $FNAME
chown glance:glance $FNAME
chmod 644 $FNAME
}


# START
. conf/alldeploy.conf
HOST_IP=`echo $MANAGE_IP | gawk -F'/' '{ print $1 }'`
GLANCE_API
GLANCE_REGISTRY
/usr/bin/glance-manage db_sync  >> log/deploy.log 2>&1
for i in glance-registry glance-api
do
systemctl restart $i.service
echo "Service $i Restart"  >> log/deploy.log 2>&1
done
rm -f /var/lib/glance/glance.sqlite

# GLANCE FINISH

echo "########################################################" >> log/deploy.log 2>&1
echo "OPENSTACK GLANCE DEPLOY FINISHED"                         >> log/deploy.log 2>&1
echo "########################################################" >> log/deploy.log 2>&1