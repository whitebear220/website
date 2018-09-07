#!/bin/bash

# $1 = name $2 = file
. conf/alldeploy.conf
. admin_openrc

/usr/bin/glance image-create --name "$1" --file $2 --disk-format qcow2 --container-format bare --visibility public --progress
