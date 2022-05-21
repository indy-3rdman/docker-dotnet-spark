ARG DOTNET_SPARK_VERSION=2.1.0
FROM dotnet-spark-base-runtime:$DOTNET_SPARK_VERSION
LABEL maintainer="Martin Kandlbinder <indy@3rdman.de>"

ARG HADOOP_VERSION=3.2.3

RUN echo "Downloading hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz ..." \
    && wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xvzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt/ \
    && rm hadoop-${HADOOP_VERSION}.tar.gz \
    && mkdir /hadoop-data\
    && mkdir /opt/hadoop-$HADOOP_VERSION/logs \
    && ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ \
    HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION} \
    HADOOP_CONF_DIR=/etc/hadoop

ENV PATH="${HADOOP_HOME}/bin:${PATH}"
