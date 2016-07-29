#!/bin/bash
user="cinder"
conf="/etc/ceph/ceph.conf"
pool="volumes"

rbd --user $user --conf $conf -p $pool ls
