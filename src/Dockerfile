FROM fvigotti/docker-fatjdk8

MAINTAINER fvigotti

ENV KAFKA_VERSION="0.8.2.1" SCALA_VERSION="2.10"

ADD download-kafka.sh /tmp/download-kafka.sh

RUN chmod +x /tmp/download-kafka.sh && \
    /tmp/download-kafka.sh && \
    tar xf /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt

RUN mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

VOLUME ["/kafka"]
VOLUME ["/opt/kafka/logs"]

ADD start-kafka.sh /usr/bin/start-kafka.sh
RUN chmod +x /usr/bin/start-kafka.sh

#ENV KAFKA_HOME /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
ENV KAFKA_HOME /opt/kafka

CMD ["/bin/bash" , "start-kafka.sh"]

