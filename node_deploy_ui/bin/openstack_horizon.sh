#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

function HORIZON()
{
FNAME=/etc/openstack-dashboard/local_settings.py
INAME=file/local_settings.py
cp $FNAME $FNAME.bak
cp $INAME $FNAME
sed -e "s,%HA_HOST%,$CT_HOST,g" -i $FNAME
}


#START
. conf/alldeploy.conf

HORIZON

# for ocata bug need add
# chown www-data:www-data /var/lib/openstack-dashboard/secret_key
systemctl reload apache2.service
systemctl restart apache2.service

echo "########################################################"  >> log/deploy.log 2>&1
echo "OPENSTACK HORIZON DEPLOY FINISHED"  >> log/deploy.log 2>&1
echo "########################################################"  >> log/deploy.log 2>&1