#!/bin/bash
user="cinder"
conf="/etc/ceph/ceph.conf"
pool="volumes"
volume_id=$1

if [ -z $1 ];
then
    echo "Usage: $1 <volume_id>"
    exit
fi

rbd --user $user --conf $conf snap ls $pool/"volume-$volume_id"
