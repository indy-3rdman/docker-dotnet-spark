# docker-dotnet-spark

![Icon](resource/docker-dotnet-spark.png)

## Description

This repository contains the source code to build a docker image that allows you to test out [.NET for Apache Spark](https://dotnet.microsoft.com/apps/data/spark).

You can get the pre-built images directly from the the docker hub at [https://hub.docker.com/r/3rdman/dotnet-spark](https://hub.docker.com/r/3rdman/dotnet-spark).

Using this image you can

- run a spark master and multiple slaves within the same container.
- run spark master and slave instances in separate containers.
- connect to a .NET for Apache Spark session in debug mode from Visual Studio or Visual Studio Code.

More details about using the image are available at [3rdman.de](https://3rdman.de/tag/net-for-apache-spark/), or the docker hub page mentioned above.

## Building

To build an image just run the [build.sh](build.sh) bash script. Per default it should build an image with the latest supported versions of .NET Core, Apache Spark and .NET for Apache Spark installed.

You can also build for different versions by specifying the options below.
Please note, that not all combinations are supported, however.

```
    -a, --apache-spark
    -d, --dotnet-spark
```

For more details please run

```
build.sh -h
```

You can also specify an proxy option (-p, --proxy), in case you do not have direct access to the internet. Currently, the same `PROXY` is used for both, HTTP and HTTPS. This might change in the future.



## The stages

Using different stages makes sense for building multiple images that are based on the same .NET core SDK, but are using different .NET for Apache Spark or Apache Spark versions.
By dividing it up, the same packages (e.g. .NET core SDK) do not need to be downloaded again and again for each different Apache Spark version. This saves time and bandwidth.
The three stages are:

- **dotnet-sdk**: Downloads and installs the specified .NET core SDK into a base Ubuntu 18.04 image along with some other tools that might be required by later stages or for debugging.

- **dotnet-spark-base**: Adds the specified .NET for Apache Spark version to the dotnet-sdk image and also copies/builds the HelloSpark example to get the correct microsoft-spark-*.jar version that is required for using the image for debugging [debugging .NET for Apache Spark](https://docs.microsoft.com/en-us/dotnet/spark/how-to-guides/debug) via Visual Studio, or Visual Studio Code.
![Debug](resource/dotnet-spark-vsc-debug.gif)

- **dotnet-spark**: Gets/installs the Apache Spark version and copies the related startup scripts into the image.

## Docker Run Examples

- ### master and one slave in a single container

```bash
docker run -d --name dotnet-spark -p 8080:8080 -p 8081:8081 -e SPARK_DEBUG_DISABLED=true 3rdman/dotnet-spark:latest
```

- ### master and two slaves in a single container

```bash
docker run -d --name dotnet-spark -p 8080:8080 -p 8081:8081 -p 8081:8081 -e SPARK_DEBUG_DISABLED=true -e SPARK_WORKER_INSTANCES=2 3rdman/dotnet-spark:latest
```

- ### master only

```bash
docker run -d --name dotnet-spark-master -p 8080:8080 -p 7077:7077 -e SPARK_DEBUG_DISABLED=true -e SPARK_WORKER_INSTANCES=0 3rdman/dotnet-spark:latest
```

- ### slave only, connecting to external master

```bash
docker run -d --name dotnet-spark-slave -p 8080:8080 -e SPARK_DEBUG_DISABLED=true -e SPARK_MASTER_DISABLED=true -e SPARK_MASTER_URL="spark://master-hostname:7077" 3rdman/dotnet-spark:latest
```

For details about how to use the image for .NET for Apache Spark debugging, please have a look at one of the following posts:

- [.NET for Apache Spark – VSCode with Docker on Linux and df.Collect()](https://3rdman.de/2020/01/net-for-apache-spark-visual-studio-code-with-docker-on-linux/)

- [.NET for Apache Spark – UDF, VS2019, Docker for Windows and a Christmas Puzzle](https://3rdman.de/2019/12/net-for-apache-spark-udf-vs2019-docker-for-windows-and-a-christmas-puzzle/)

- [Debug .NET for Apache Spark with Visual Studio and docker](https://3rdman.de/2019/10/debug-net-for-apache-spark-with-visual-studio-and-docker/)

## Other References

The unofficial .NET for Apache Spark logo at the top is an adaption of, and base on, the [Docker logo](https://en.wikipedia.org/wiki/Docker_(software)#/media/File:Docker_(container_engine)_logo.svg) and the [Apache Spark logo](https://en.wikipedia.org/wiki/Apache_Spark#/media/File:Apache_Spark_logo.svg).

