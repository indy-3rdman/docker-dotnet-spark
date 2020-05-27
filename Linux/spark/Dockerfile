ARG DOTNET_SPARK_VERSION=0.11.0
FROM 3rdman/dotnet-spark:$DOTNET_SPARK_VERSION-base-linux

ARG SPARK_VERSION=2.4.5

ENV DAEMON_RUN=true
ENV SPARK_VERSION=$SPARK_VERSION
ENV SPARK_HOME=/spark

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_MASTER_DISABLED=""
ENV SPARK_MASTER_URL=""

ENV SPARK_WORKER_PORT 7078
ENV SPARK_WORKER_WEBUI_PORT 8081
ENV SPARK_WORKER_INSTANCES=1

ENV SPARK_SUBMIT_PACKAGES=""
ENV SPARK_DEBUG_DISABLED=""
ENV HADOOP_VERSION=2.7
ENV PATH="${SPARK_HOME}/bin:${DOTNET_WORKER_DIR}:${PATH}"

COPY sbin /sbin/
COPY supervisor.conf /etc/supervisor.conf

RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark \
    && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && chmod 755 /sbin/start-spark-slave.sh \
    && chmod 755 /sbin/start-spark-master.sh \
    && chmod 755 /sbin/start-spark-debug.sh

EXPOSE 8080 8081 8082 7077 6066 5567 4040

CMD ["supervisord", "-c", "/etc/supervisor.conf"]
