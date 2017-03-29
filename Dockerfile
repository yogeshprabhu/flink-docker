FROM larsvh/scala-arm 

ARG HADOOP_VERSION=27
ARG FLINK_VERSION=1.2.0
ARG SCALA_BINARY_VERSION=2.11

ENV FLINK_INSTALL_PATH /opt
ENV FLINK_HOME $FLINK_INSTALL_PATH/flink
ENV PATH $PATH:$FLINK_HOME/bin
RUN echo "ipv6" >> /etc/modules
RUN mkdir -p /etc/apk && \
    echo "http://dl-1.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories; \
    echo "http://dl-2.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories; \
    echo "http://dl-3.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories; \
    echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories; \
    echo "http://dl-5.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN apt-get update; apt-get install -y curl wget 
RUN set -x && \
    mkdir -p ${FLINK_INSTALL_PATH} && \
    curl -Ls  'http://ftp.wayne.edu/apache/flink/flink-1.2.0/flink-1.2.0-bin-hadoop27-scala_2.11.tgz' | \ 
    tar xz -C ${FLINK_INSTALL_PATH} && \
    ln -s ${FLINK_INSTALL_PATH}/flink-${FLINK_VERSION} ${FLINK_HOME} && \
    sed -i -e "s/echo \$mypid >> \$pid/echo \$mypid >> \$pid \&\& wait/g" ${FLINK_HOME}/bin/flink-daemon.sh && \
    sed -i -e "s/ > \"\$out\" 2>&1 < \/dev\/null//g" ${FLINK_HOME}/bin/flink-daemon.sh && \
    rm -rf /var/cache/apk/* && \
    echo Installed Flink ${FLINK_VERSION} to ${FLINK_HOME}

ADD docker-entrypoint.sh ${FLINK_HOME}/bin/
# Additional output to console, allows gettings logs with 'docker-compose logs'
ADD log4j.properties ${FLINK_HOME}/conf/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh", "-c"]
