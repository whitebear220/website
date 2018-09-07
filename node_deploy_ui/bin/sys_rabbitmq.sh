#!/bin/bash
# Check root privilege: Make sure only root can run our script
if [ $EUID -ne 0 ] ; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#RabbitMQ create Account
/usr/sbin/rabbitmqctl add_user localadmin openstack                             >> log/deploy.log 2>&1
/usr/sbin/rabbitmqctl set_permissions localadmin ".*" ".*" ".*"                 >> log/deploy.log 2>&1
/usr/sbin/rabbitmq-plugins enable rabbitmq_management                           >> log/deploy.log 2>&1
echo '[{rabbit, [{loopback_users, []}]}].' > /etc/rabbitmq/rabbitmq.config
systemctl restart rabbitmq-server.service                                       >> log/deploy.log 2>&1


echo "########################################################" >> log/deploy.log
/usr/sbin/rabbitmqctl cluster_status                            >> log/deploy.log 2>&1
echo "RABBITMQ DEPLOY FINISHED"                                 >> log/deploy.log
echo "########################################################" >> log/deploy.log