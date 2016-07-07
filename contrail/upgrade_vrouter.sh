#!/bin/bash

service supervisor-vrouter stop
rmmod vrouter
apt-get -y -o Dpkg::Options::="--force-confold" install contrail-openstack-vrouter contrail-vrouter-dkms
service supervisor-vrouter restart
