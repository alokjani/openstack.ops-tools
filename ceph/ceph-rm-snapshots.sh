#!/bin/bash
user="cinder"
conf="/etc/ceph/ceph.conf"
pool="volumes"
volume_id=$1
snap_id=$2

if [ -z $1 ];
then
    echo "Usage: $0 <volume_id> <snapshot_id>"
    exit
fi    

snap_name=$(rbd --user $user --conf $conf snap ls $pool/"volume-$volume_id" | grep $snap_id|awk '{print $2}') 
echo $snap_name
rbd --user $user --conf $conf snap rm $pool/"volume-$volume_id@$snap_name"
