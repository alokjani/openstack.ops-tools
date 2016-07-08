#!/bin/bash
# make_ssd_journal.sh <osd#> <ssd disk partition#>
# ex. 'make_ssd_journal.sh 112 /dev/sdaa7'
#   this will switch OSD# 112's journal from onfile to onpartition
#   where the partition sdaa7 is the 7th partition on SSD disk sdaa
#
# Mirantis Fuel by default uses a file based journal for Ceph OSDs
# This program switches OSD's journal from file based to that of SSD partition

set -x

# -- Stop Ceph OSD
stop ceph-osd id=$1

# -- Flush Journal
ceph-osd --flush-journal -i $1

# -- Remove file based journal and point to the SSD disk partition to be used as Ceph Journal

mv /var/lib/ceph/osd/ceph-$1/journal /var/lib/ceph/osd/ceph-$1/journal-file.old
ln -s /dev/$2 /var/lib/ceph/osd/ceph-$1/journal

# -- Create a new journal (which will now be on SSD partition) for the OSD# $1

ceph-osd --mkjournal -i $1

# -- Start the OSD, so that now it uses its journal writes go to SSD
start ceph-osd id=$1

