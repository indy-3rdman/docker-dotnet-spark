# docker-dotnet-spark

![Icon](resource/docker-dotnet-spark.png)

[![Build status](https://ci.appveyor.com/api/projects/status/70p9mg7r670evo7m?svg=true)](https://ci.appveyor.com/project/indy/docker-dotnet-spark) &nbsp;&nbsp; [![Binder](resource/dotnet-spark-binder.svg)](https://mybinder.org/v2/gh/indy-3rdman/docker-dotnet-spark/master?urlpath=lab)

## Description

This repository contains the source code to build a variety of different docker images related to [.NET for Apache Spark](https://dotnet.microsoft.com/apps/data/spark).

You can also get the pre-built images directly from the the docker hub at [https://hub.docker.com/r/3rdman/dotnet-spark](https://hub.docker.com/r/3rdman/dotnet-spark).

Currently, there are three different image types.

- [runtime](images/runtime/README.md)

   The runtime images contain everything you need to test your .NET for Apache Spark application, without the need to install all the required bits manually.

- [dev](images/dev/README.md)

  Use these images, if you want to build .NET for Apache Spark yourself.

- [interactive](images/interactive/README.md)

  Lets you play around with .NET for Apache Spark in an Interactive Notebook.

- [runtime-hadoop](images/runtime-hadoop/README.md)

  Same as the runtime image, but with a full Hadoop version

## Other References

The unofficial .NET for Apache Spark logo at the top is an adaption of, and base on, the [Docker logo](https://en.wikipedia.org/wiki/Docker_(software)#/media/File:Docker_(container_engine)_logo.svg) and the [Apache Spark logo](https://en.wikipedia.org/wiki/Apache_Spark#/media/File:Apache_Spark_logo.svg).