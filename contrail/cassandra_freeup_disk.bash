#!/bin/bash
# Alok Jani S.
# Free up diskspace used by Flows recorded in Contrail's Cassandra DB
# --

CASSANDRA_HOME="/home/cassandra/data"
CASSANDRA_KEYSPACE="ContrailAnalytics"
CASSANDRA_TABLES="FlowRecordTable FlowTableDvnDipVer2 FlowTableProtDpVer2 FlowTableProtSpVer2 FlowTableSvnSipVer2 FlowTableVRouterVer2"

for TBL in $CASSANDRA_TABLES; do du -sh "$CASSANDRA_HOME/$CASSANDRA_KEYSPACE/$TBL" ; done

for TBL in $CASSANDRA_TABLES; do
  echo "Running major compaction for table $CASSANDRA_KEYSPACE.$TBL"
  nodetool compact $CASSANDRA_KEYSPACE $TBL
done

for TBL in $CASSANDRA_TABLES; do du -sh "$CASSANDRA_HOME/$CASSANDRA_KEYSPACE/$TBL" ; done
