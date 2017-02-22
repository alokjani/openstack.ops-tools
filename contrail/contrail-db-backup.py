#!/usr/bin/env python
"""
Extract & Backup Contrail's keyspaces from Cassandra Database on Contrail Controllers
"""

import yaml
import pycassa.system_manager
import datetime
import subprocess
import os
import shutil
import argparse


parser = argparse.ArgumentParser()
parser.add_argument("--existing-snapshot", help="optional name of existing snapshot")
args = parser.parse_args()

cass_config = '/etc/cassandra/cassandra.yaml'
cass_keyspaces_exclude = ['system', 'system_traces', 'ContrailAnalytics', 'OpsCenter']
#cass_keyspaces_exclude = []
backup_dir_base = '/data/database_backup/';

shutil.rmtree(backup_dir_base, ignore_errors=True)

with open(cass_config, 'r') as stream:
    cass_config_dict = yaml.load(stream)

cass_ip = cass_config_dict['listen_address']
cass_datadirs = cass_config_dict['data_file_directories']
#print cass_ip
#print cass_datadirs

cass_sm = pycassa.system_manager.SystemManager(cass_ip+':9160')
cass_keyspaces = cass_sm.list_keyspaces()
#cass_sm.close()
#print cass_keyspaces
snapshot_keyspaces = [item for item in cass_keyspaces if item not in cass_keyspaces_exclude]
#print snapshot_keyspaces

if args.existing_snapshot:
  snapshot_name = args.existing_snapshot
else:
  snapshot_name = 'snap-'+datetime.datetime.now().strftime("%Y%m%d%H%M%S")
  print snapshot_name
  snapshot_call =  ['/usr/bin/nodetool', 'snapshot'] + snapshot_keyspaces + ['-t', snapshot_name]
  #.extend(snapshot_keyspaces)
  subprocess.call(snapshot_call)

#for sk in snapshot_keyspaces:
#  print sk, cass_sm.get_keyspace_column_families(sk).keys()

for cd in cass_datadirs:
  for sk in snapshot_keyspaces:
    for cf in cass_sm.get_keyspace_column_families(sk).keys():
      source_dir = os.path.join(cd, sk, cf, 'snapshots', snapshot_name)
      dest_dir = os.path.join(backup_dir_base, 'var_lib_cassandra_data', sk, cf)
      try:
        for f in next(os.walk(source_dir))[2]:
          if not os.path.exists(dest_dir):
            os.makedirs(dest_dir)

          source_file = os.path.join(source_dir, f)
          dest_file = os.path.join(dest_dir, f)

          print source_file + ' -> ' + dest_file

          shutil.copy (source_file, dest_file)

      except StopIteration:
        pass



cass_sm.close()

shutil.copytree('/var/lib/zookeeper/version-2', os.path.join(backup_dir_base, 'var_lib_zookeeper_version-2'))

print
print 'Data copied to ' + backup_dir_base

clear_snapshot_call =  ['/usr/bin/nodetool', 'clearsnapshot', '-t', snapshot_name]
subprocess.call(clear_snapshot_call)
