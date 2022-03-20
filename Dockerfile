FROM java:openjdk-8-jdk

ENV spark_ver 3.0.2

# Get Spark from US Apache mirror.
RUN mkdir -p /opt && \
    cd /opt && \
    curl https://archive.apache.org/dist/spark/spark-3.0.2/spark-3.0.2-bin-hadoop3.2.tgz | \
        tar -zx && \
    ln -s spark-3.0.2-bin-hadoop3.2 spark && \
    echo Spark ${spark_ver} installed in /opt

ENV PATH $PATH:/opt/spark/bin

RUN mkdir /opt/spark/docker-configs

RUN echo "#!/bin/bash" >> /opt/spark/docker-configs/common.sh
RUN echo "unset SPARK_MASTER_PORT" >> /opt/spark/docker-configs/common.sh

RUN echo "#!/bin/bash" >> /opt/spark/docker-configs/spark-master
RUN echo ". /opt/spark/docker-configs/common.sh" >> /opt/spark/docker-configs/spark-master
RUN echo 'echo "$(hostname -i) spark-master" >> /etc/hosts' >> /opt/spark/docker-configs/spark-master
RUN echo "/opt/spark/bin/spark-class org.apache.spark.deploy.master.Master --ip spark-master --port 7077 --webui-port 8080" >> /opt/spark/docker-configs/spark-master

RUN echo "spark.master spark://spark-master:7077" >> /opt/spark/conf/spark-defaults.conf

RUN echo "#!/bin/bash" >> /opt/spark/docker-configs/spark-worker

RUN echo ". /opt/spark/docker-configs/common.sh" >> /opt/spark/docker-configs/spark-worker

RUN echo "if ! getent hosts spark-master; then "  >> /opt/spark/docker-configs/spark-worker
RUN echo "sleep 5 "  >> /opt/spark/docker-configs/spark-worker
RUN echo "exit 0 " >> /opt/spark/docker-configs/spark-worker
RUN echo "fi" >> /opt/spark/docker-configs/spark-worker
RUN echo "/opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://spark-master:7077 --memory 1g  --cores 1 --webui-port 8081" >> /opt/spark/docker-configs/spark-worker

RUN chmod +x /opt/spark/docker-configs/spark-master /opt/spark/docker-configs/spark-worker /opt/spark/docker-configs/common.sh

RUN more /opt/spark/docker-configs/spark-worker
