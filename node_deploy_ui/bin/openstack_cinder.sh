#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

function CINDER()
{
FNAME=/etc/cinder/cinder.conf
INAME=file/cinder.conf
cp $FNAME $FNAME.bak
cp $INAME $FNAME
sed -e "s,%HOST_IP%,$HOST_IP,g" -i $FNAME
sed -e "s,%HA_HOST%,$CT_HOST,g" -i $FNAME
sed -e "s,%CINDER_DB%,$OPENSTACK_DBPASS,g" -i $FNAME
chown cinder:cinder $FNAME
chmod 644 $FNAME
}




#START
. conf/alldeploy.conf
STATE=$1
case $STATE  in
    "MASTER")
    	HOST_IP=`echo $MANAGE_IP_A | gawk -F'/' '{ print $1 }'`
	;;
    "BACKUP")
    	HOST_IP=`echo $MANAGE_IP_B | gawk -F'/' '{ print $1 }'`
	;;
    "cinder")
    	HOST_IP=`echo $2 | gawk -F'/' '{ print $1 }'`
	;;
esac

#cinder
if [[ $STATE == "MASTER" ]] || [[ $STATE == "BACKUP" ]]; then
CINDER
/usr/bin/cinder-manage db sync
for i in nova-api cinder-scheduler cinder-api
do
systemctl stop $i.service
systemctl start $i.service
done

elif [[ $STATE == "CINDER" ]]; then
#lvm

systemctl stop cinder-volume.service
systemctl start cinder-volume.service
fi

echo "########################################################"
echo "OPENSTACK CINDER DEPLOY FINISHED"
echo "########################################################"