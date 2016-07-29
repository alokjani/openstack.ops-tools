#!/bin/bash
conf="/etc/ceph/ceph.conf"
pool="volumes"
volume_id=$1
snap_id=$2

if [ -z $1 ];
then
    echo "Usage: $0 <volume_id> "
    exit
fi    

rbd --conf $conf snap purge $pool/"volume-$volume_id"
