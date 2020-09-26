#!/bin/bash
if [ -z "$SPARK_MASTER_URL" ]; then
    $SPARK_HOME/sbin/start-slave.sh spark://`hostname`:7077
else
    $SPARK_HOME/sbin/start-slave.sh $SPARK_MASTER_URL
fi