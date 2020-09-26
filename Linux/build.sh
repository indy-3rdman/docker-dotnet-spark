#!/bin/bash

# Create different versions of the .NET for Apache Spark docker image
# based on the Apach Spark and .NET for Apache Spark version.

set -e

DOTNET_CORE_VERSION=3.1
DOTNET_SPARK_VERSION=0.12.1
APACHE_SPARK_VERSION=2.4.6
APACHE_SPARK_SHORTVER="${APACHE_SPARK_VERSION:0:3}"
PROXY=""

IMG_REPOSITORY="3rdman"

SUPPORTED_APACHE_SPARK_VERSIONS=("2.3.3" "2.3.4" "2.4.0" "2.4.1" "2.4.3" "2.4.4" "2.4.5" "2.4.6")
SUPPORTED_DOTNET_SPARK_VERSIONS=("0.9.0" "0.10.0" "0.11.0" "0.12.1")

#######################################
# Checks if the provided Apache Spark version number is supported
# Arguments:
#   The version number string
# Result:
#   Sets the global variable APACHE_SPARK_VERSION if supported,
#       otherwise exits with a related message
#######################################
opt_check_apache_spark_version() {
    if [[ " ${SUPPORTED_APACHE_SPARK_VERSIONS[@]} " =~ " $1 " ]]; then
        APACHE_SPARK_VERSION="$1"
        APACHE_SPARK_SHORTVER="${APACHE_SPARK_VERSION:0:3}"
    else
        echo "$1 is an unsupported Apache Spark version."
        exit 1 ;
    fi
}

#######################################
# Checks if the provided .NET for Apache Spark version number is supported
# Arguments:
#   The version number string
# Result:
#   Sets the global variable DOTNET_SPARK_VERSION if supported,
#       otherwise exits with a related message
#######################################
opt_check_dotnet_spark_version() {
    if [[ " ${SUPPORTED_DOTNET_SPARK_VERSIONS[@]} " =~ " $1 " ]]; then
        DOTNET_SPARK_VERSION="$1"
    else
        echo "$1 is an unsupported .NET for Apache Spark version."
        exit 1 ;
    fi
}

#######################################
# Checks if the argument seems to be a valid proxy URL
# Arguments:
#   The URL string
# Result:
#   Sets the global PROXY variable if valid,
#       otherwise exits with a related message
#######################################
opt_check_proxy() {
    if [[ $1 =~ ^http://.+|^https://.+ ]]; then
        PROXY="$1"
    else
        echo "$1 seems to be an invalid proxy."
        exit 1 ;
    fi
}

#######################################
# Replaces every occurence of search_string by replacement_string in a file
# Arguments:
#   The file name
#   The string to search for
#   The string to replace the search string with
# Result:
#   An updated file with the replaced string
#######################################
replace_text_in_file() {
    filename=$1
    search_string=$2
    replacement_string=$3

    sh -c 'sed -i.bak "s/$1/$2/g" "$3" && rm "$3.bak"' _ "$search_string" "$replacement_string" $filename
}

#######################################
# Runs the docker build command with the related build arguments
# Arguments:
#   The image name (incl. tag)
# Result:
#   A local docker image with the specified name
#######################################
build_image() {
    local image_name="$1"
    local build_args="--build-arg DOTNET_CORE_VERSION=$DOTNET_CORE_VERSION --build-arg DOTNET_SPARK_VERSION=$DOTNET_SPARK_VERSION --build-arg SPARK_VERSION=$APACHE_SPARK_VERSION"

    if ! [ -z "$PROXY" ]
    then
        build_args+=" --build-arg HTTP_PROXY=$PROXY --build-arg HTTPS_PROXY=$PROXY"
    fi

    echo "Building $image_name"

    docker build $build_args -t $image_name .
}

#######################################
# Use the Dockerfile in the sub-folder dotnet-sdk to build the image of the first stage
# Result:
#   A dotnet-sdk-linux docker image tagged with the .NET core version
#######################################
build_dotnet_sdk_linux() {
    local image_name="$IMG_REPOSITORY/dotnet-sdk:$DOTNET_CORE_VERSION-linux"

    cd dotnet-sdk

    build_image $image_name

    cd ~-
}

#######################################
# Use the Dockerfile in the sub-folder dotnet-spark to build the image of the second stage
# The image contains the specified .NET for Apache Spark version plus the HelloSpark example
#   for the correct TargetFramework and Microsoft.Spark package version
# Result:
#   A dotnet-spark-base docker image tagged with the .NET core version and the suffix -linux
#######################################
build_dotnet_spark_base_linux() {
    local image_name="$IMG_REPOSITORY/dotnet-spark-base:$DOTNET_SPARK_VERSION-linux"

    cd dotnet-spark

    cp -r templates/HelloSpark ./HelloSpark

    replace_text_in_file HelloSpark/HelloSpark.csproj "<TargetFramework><\/TargetFramework>" "<TargetFramework>netcoreapp${DOTNET_CORE_VERSION}<\/TargetFramework>"
    replace_text_in_file HelloSpark/HelloSpark.csproj "PackageReference Include=\"Microsoft.Spark\" Version=\"\"" "PackageReference Include=\"Microsoft.Spark\" Version=\"${DOTNET_SPARK_VERSION}\""

    replace_text_in_file HelloSpark/README.txt "netcoreappX.X" "netcoreapp${DOTNET_CORE_VERSION}"
    replace_text_in_file HelloSpark/README.txt "spark-X.X.X" "spark-${APACHE_SPARK_SHORTVER}.x"
    replace_text_in_file HelloSpark/README.txt "spark-${APACHE_SPARK_SHORTVER}.x-X.X.X.jar" "spark-${APACHE_SPARK_SHORTVER}.x-${DOTNET_SPARK_VERSION}.jar"

    build_image $image_name

    cd ~-
}

#######################################
# Use the Dockerfile in the sub-folder apache-spark to build the image of the last stage
# The image contains the specified Apache Spark version
# Result:
#   A dotnet-spark docker image tagged with the .NET core version and the suffix -linux
#######################################
build_dotnet_spark_linux() {
    local image_name="$IMG_REPOSITORY/dotnet-spark:$DOTNET_SPARK_VERSION-spark-$APACHE_SPARK_VERSION-linux"

    cd apache-spark
    cp -r templates/sbin ./sbin

    replace_text_in_file sbin/start-spark-debug.sh "microsoft-spark-X.X.X" "microsoft-spark-${APACHE_SPARK_SHORTVER}.x"

    build_image $image_name

    cd ~-
}

#######################################
# Remove the temporary folders created during the different build stages
#######################################
cleanup()
{
    cd apache-spark
    rm -rf sbin
    cd ~-
    cd dotnet-spark
    rm -rf HelloSpark
    cd ~-
}

#######################################
# Display the help text
#######################################
print_help() {
  cat <<EOF
Usage: build.sh [OPTIONS]"

Builds a .NET for Apache Spark runtime docker image

Options:
    -a, --apache-spark    A supported Apache Spark version to be used within the image
    -d, --dotnet-spark    The .NET for Apache Spark version to be used within the image
    -p, --proxy           Proxy to be used in case no direct access to the internet is available
    -h, ----help          Show this usage help

If -a or -d is not defined, default values are used

DOTNET_SPARK_VERSION $DOTNET_SPARK_VERSION
APACHE_SPARK_VERSION $APACHE_SPARK_VERSION
EOF
}


# Parse the options an set the related variables
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -a|--apache-spark) opt_check_apache_spark_version "$2"; shift ;;
        -d|--dotnet-spark) opt_check_dotnet_spark_version "$2"; shift ;;
        -p|--proxy) opt_check_proxy "$2"; shift;; 
        -h|--help) print_help
            exit 1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "Building .NET for Apache Spark $DOTNET_SPARK_VERSION linux image with Apache Spark $APACHE_SPARK_VERSION"

# execute the different build stages
cleanup
build_dotnet_sdk_linux
build_dotnet_spark_base_linux
build_dotnet_spark_linux
cleanup

exit 0
