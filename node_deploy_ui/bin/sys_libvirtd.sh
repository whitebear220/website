#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#libvirtbin
FNAME=/etc/default/libvirt-bin
sed -e "s,^#libvirtd_opts=\"\",libvirtd_opts=\"-d -l\",g" -i $FNAME

INAME=/etc/libvirt/libvirtd.conf
sed -e "s,^#listen_tls = 0,listen_tls = 0,g" -i $INAME
sed -e "s,^#listen_tcp = 1,listen_tcp = 1,g" -i $INAME
sed -e "s,^#auth_tcp = \"sasl\",auth_tcp = \"none\",g" -i $INAME


echo "########################################################" >> log/deploy.log
echo "LIBVIRTD DEPLOY FINISHED"                                 >> log/deploy.log
echo "########################################################" >> log/deploy.log