#!/usr/bin/env bash

# Start the .NET for Apache Spark backend in debug mode
cd "${HOME}"/dotnet.spark  || exit
/spark/bin/spark-submit --class org.apache.spark.deploy.dotnet.DotnetRunner --jars "${HOME}/dotnet.spark/*.jar" --master local microsoft-spark-X.X.X-"${DOTNET_SPARK_VERSION}".jar debug 5567
