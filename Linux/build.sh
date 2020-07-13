#!/bin/bash

set -e

DOTNET_CORE_VERSION=3.1
DOTNET_SPARK_VERSION=0.12.1
SPARK_VERSION=2.4.5
PROXY=""
SHORTVER="${SPARK_VERSION:0:3}"

replace_text_with_sed()
{
    filename=$1
    original_text=$2
    final_text=$3

    sh -c 'sed -i.bak "s/$1/$2/g" "$3" && rm "$3.bak"' _ "$original_text" "$final_text" $filename
}

build_dotnet-sdk-linux()
{
    cd dotnet-sdk
    if [ -z "$PROXY" ]
    then
        docker build --build-arg DOTNET_CORE_VERSION=$DOTNET_CORE_VERSION -t 3rdman/dotnet-sdk-linux:$DOTNET_CORE_VERSION .
    else
        docker build --build-arg DOTNET_CORE_VERSION=$DOTNET_CORE_VERSION -t 3rdman/dotnet-sdk-linux:$DOTNET_CORE_VERSION . \
            --build-arg http_proxy=$PROXY \
            --build-arg https_proxy=$PROXY \
            --build-arg HTTP_PROXY=$PROXY \
            --build-arg HTTPS_PROXY=$PROXY
    fi
    cd -
}

build_dotnet-spark-base-linux()
{
    cd dotnet-spark
    rm -rf HelloSpark
    cp -r templates/HelloSpark ./HelloSpark

    replace_text_with_sed HelloSpark/HelloSpark.csproj "<TargetFramework><\/TargetFramework>" "<TargetFramework>netcoreapp${DOTNET_CORE_VERSION}<\/TargetFramework>"
    replace_text_with_sed HelloSpark/HelloSpark.csproj "PackageReference Include=\"Microsoft.Spark\" Version=\"\"" "PackageReference Include=\"Microsoft.Spark\" Version=\"${DOTNET_SPARK_VERSION}\""

    replace_text_with_sed HelloSpark/README.txt "netcoreappX.X" "netcoreapp${DOTNET_CORE_VERSION}"
    replace_text_with_sed HelloSpark/README.txt "spark-X.X.X" "spark-${SHORTVER}.x"
    replace_text_with_sed HelloSpark/README.txt "spark-${SHORTVER}.x-X.X.X.jar" "spark-${SHORTVER}.x-${DOTNET_SPARK_VERSION}.jar"

    if [ -z "$PROXY" ]
    then
        docker build --build-arg DOTNET_SPARK_VERSION=$DOTNET_SPARK_VERSION -t 3rdman/dotnet-spark:$DOTNET_SPARK_VERSION-base-linux .
    else
        docker build --build-arg DOTNET_SPARK_VERSION=$DOTNET_SPARK_VERSION -t 3rdman/dotnet-spark:$DOTNET_SPARK_VERSION-base-linux . \
            --build-arg http_proxy=$PROXY \
            --build-arg https_proxy=$PROXY \
            --build-arg HTTP_PROXY=$PROXY \
            --build-arg HTTPS_PROXY=$PROXY
    fi
    cd -
}

build_dotnet-spark-linux()
{
    cd spark
    rm -rf sbin
    cp -r templates/sbin ./sbin

    replace_text_with_sed sbin/start-spark-debug.sh "microsoft-spark-X.X.X" "microsoft-spark-${SHORTVER}.x"
    if [ -z "$PROXY" ]
    then
        docker build --build-arg DOTNET_SPARK_VERSION=$DOTNET_SPARK_VERSION --build-arg SPARK_VERSION=$SPARK_VERSION -t 3rdman/dotnet-spark:$DOTNET_SPARK_VERSION-spark-$SPARK_VERSION-linux .
    else
        docker build --build-arg DOTNET_SPARK_VERSION=$DOTNET_SPARK_VERSION --build-arg SPARK_VERSION=$SPARK_VERSION -t 3rdman/dotnet-spark:$DOTNET_SPARK_VERSION-spark-$SPARK_VERSION-linux . \
            --build-arg http_proxy=$PROXY \
            --build-arg https_proxy=$PROXY \
            --build-arg HTTP_PROXY=$PROXY \
            --build-arg HTTPS_PROXY=$PROXY
    fi
    cd -
}

build_dotnet-sdk-linux
build_dotnet-spark-base-linux
build_dotnet-spark-linux
