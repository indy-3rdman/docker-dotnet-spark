#!/bin/bash

set -e

DOTNET_CORE_VERSION=3.1
DOTNET_SPARK_VERSION=0.11.0
SPARK_VERSION=2.4.5
SHORTVER="${SPARK_VERSION:0:3}"

build_dotnet-sdk-linux()
{
    cd dotnet-sdk
    docker build --build-arg DOTNET_CORE_VERSION=$DOTNET_CORE_VERSION -t 3rdman/dotnet-sdk-linux:$DOTNET_CORE_VERSION .
    cd -
} 

build_dotnet-spark-base-linux()
{
    cd dotnet-spark
    rm -rf HelloSpark
    cp -r templates/HelloSpark ./HelloSpark
    sed -i "s/<TargetFramework><\/TargetFramework>/<TargetFramework>netcoreapp${DOTNET_CORE_VERSION}<\/TargetFramework>/g" HelloSpark/HelloSpark.csproj
    sed -i "s/PackageReference Include=\"Microsoft.Spark\" Version=\"\"/PackageReference Include=\"Microsoft.Spark\" Version=\"${DOTNET_SPARK_VERSION}\"/g" HelloSpark/HelloSpark.csproj
    
    sed -i "s/netcoreappX.X/netcoreapp${DOTNET_CORE_VERSION}/g" HelloSpark/README.txt
    sed -i "s/spark-X.X.X/spark-${SHORTVER}.x/g" HelloSpark/README.txt
    sed -i "s/spark-${SHORTVER}.x-X.X.X.jar/spark-${SHORTVER}.x-${DOTNET_SPARK_VERSION}.jar/g" HelloSpark/README.txt
    docker build --build-arg DOTNET_SPARK_VERSION=$DOTNET_SPARK_VERSION -t 3rdman/dotnet-spark:$DOTNET_SPARK_VERSION-base-linux .
    cd -
} 

build_dotnet-spark-linux()
{
    cd spark
    rm -rf sbin
    cp -r templates/sbin ./sbin

    sed -i "s/microsoft-spark-X.X.X/microsoft-spark-${SHORTVER}.x/g" sbin/start-spark-debug.sh
    docker build --build-arg DOTNET_SPARK_VERSION=$DOTNET_SPARK_VERSION --build-arg SPARK_VERSION=$SPARK_VERSION -t 3rdman/dotnet-spark:$DOTNET_SPARK_VERSION-spark-$SPARK_VERSION-linux .
    cd -
}
 
build_dotnet-sdk-linux
build_dotnet-spark-base-linux
build_dotnet-spark-linux
