#!/bin/bash
if [ -z "$SPARK_MASTER_DISABLED" ]; then
    $SPARK_HOME/sbin/start-master.sh
fi