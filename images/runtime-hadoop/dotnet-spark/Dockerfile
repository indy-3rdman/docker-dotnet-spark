ARG DOTNET_SPARK_VERSION=2.1.0
ARG HADOOP_VERSION=3.2.3
#FROM dotnet-spark-base-runtime:$DOTNET_SPARK_VERSION
FROM dotnet-spark-hadoop-runtime:$HADOOP_VERSION
LABEL maintainer="Martin Kandlbinder <indy@3rdman.de>"

ARG SPARK_VERSION=3.2.1
ENV DAEMON_RUN=true \
    HADOOP_SHORT_VERSION=3.2 \
    SPARK_DEBUG_DISABLED="" \
    SPARK_HOME=/spark \
    SPARK_MASTER_DISABLED="" \
    SPARK_MASTER_PORT=7077 \
    SPARK_MASTER_WEBUI_PORT=8080 \
    SPARK_MASTER_URL="" \
    SPARK_SUBMIT_PACKAGES="" \
    SPARK_VERSION=$SPARK_VERSION \
    SPARK_WORKER_INSTANCES=1 \
    SPARK_WORKER_PORT=7078 \
    SPARK_WORKER_WEBUI_PORT=8081
ENV PATH="${SPARK_HOME}/bin:${DOTNET_WORKER_DIR}:${PATH}"

COPY bin/* /usr/local/bin/
COPY supervisor.conf /etc/supervisor.conf
COPY HelloSpark /dotnet/HelloSpark

RUN mkdir /tempdata \
    && chmod 777 /tempdata \
    && cd /dotnet/HelloSpark \
    && dotnet build \
    && cp /dotnet/HelloSpark/bin/Debug/netcoreapp${DOTNET_CORE_VERSION}/microsoft-spark-*.jar /dotnet/Debug/netcoreapp${DOTNET_CORE_VERSION}/ \
    && cd / \
    && echo "Downloading spark-${SPARK_VERSION}-bin-without-hadoop.tgz ..." \
    && wget -q https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz \
    && tar -xvzf spark-${SPARK_VERSION}-bin-without-hadoop.tgz \
    && mv spark-${SPARK_VERSION}-bin-without-hadoop spark \
    && rm spark-${SPARK_VERSION}-bin-without-hadoop.tgz \
    && chmod 755 /usr/local/bin/start-spark-slave.sh \
    && chmod 755 /usr/local/bin/start-spark-master.sh \
    && chmod 755 /usr/local/bin/start-spark-debug.sh \
    && echo "SPARK_DIST_CLASSPATH=$(hadoop classpath)" > spark/conf/spark-env.sh \
    && chmod 755 spark/conf/spark-env.sh

EXPOSE 8080 8081 7077 6066 5567 4040

CMD ["supervisord", "-c", "/etc/supervisor.conf"]
