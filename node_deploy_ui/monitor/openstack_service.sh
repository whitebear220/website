#!/bin/bash

function OoS()
{
    STATUS=`systemctl status $1 |grep Active | gawk -F':' '{ print $2 }' | gawk -F'(' '{ print $1 }'`
    if [[ $STATUS == " active " ]];then
        echo "1"
    else
        echo "0"
    fi
}

case ${1} in
	"nova-api")
		OoS nova-api.service
	;;
	"nova-consoleauth")
		OoS nova-consoleauth.service
    ;;
	"nova-scheduler")
    	OoS nova-scheduler.service
	;;
    "nova-conductor")
    	OoS nova-conductor.service
	;;
    "nova-novncproxy")
	    OoS nova-novncproxy.service
	;;
    "nova-compute")
    	OoS nova-compute
	;;
    "neutron-server")
    	OoS neutron-server.service
	;;
    "neutron-dhcp-agent")
    	OoS neutron-dhcp-agent.service  
	;;
    "neutron-l3-agent")
    	OoS neutron-l3-agent.service
	;;
    "neutron-metadata-agent")
    	OoS neutron-metadata-agent.service
	;;
    "neutron-linuxbridge-agent")
    	OoS neutron-linuxbridge-agent.service
	;;
    "neutron-ovs-agent")
    	OoS neutron-ovs-agent.service
	;;
    "glance-api")
    	OoS glance-api.service
	;;
    "glance-registry")
    	OoS glance-registry.service
	;;
esac