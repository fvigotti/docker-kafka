## heavy rewrite of https://github.com/wurstmeister/kafka-docker/commit/7674c1c79f841609f12fffe7cccc6f41e186df8c
## with some changes.. (ie: signal forwarding from docker daemon , removed dependendency between the container and host-docker-socket )




## create topic
export LOCALIP="10.0.10.15"
docker run --rm -ti fvigotti/kafka /bin/bash -c "\$KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $LOCALIP:2181 --replication-factor 1 --partitions 1 --topic topictest"
docker run --rm -ti fvigotti/kafka /bin/bash -c "\$KAFKA_HOME/bin/kafka-topics.sh --describe --zookeeper $LOCALIP:2181 --topic topictest"


kafka-docker
============

Dockerfile for [Apache Kafka](http://kafka.apache.org/)

The image is available directly from https://registry.hub.docker.com/

##Pre-Requisites

- install docker-compose [https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)
- modify the ```KAFKA_ADVERTISED_HOST_NAME``` in ```docker-compose.yml``` to match your docker host IP (Note: Do not use localhost or 127.0.0.1 as the host ip if you want to run multiple brokers.)
- if you want to customise any Kafka parameters, simply add them as environment variables in ```docker-compose.yml```, e.g. in order to increase the ```message.max.bytes``` parameter set the environment to ```KAFKA_MESSAGE_MAX_BYTES: 2000000```. To turn off automatic topic creation set ```KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'false'```

##Usage

Sample zookeeper / kafka configuration:

- ```cd ./test/compose-single/ && docker-compose up ```


##Automatically create topics

##Automatically create topics

If you want to have kafka-docker automatically create topics in Kafka during
creation, a ```KAFKA_CREATE_TOPICS``` environment variable can be
added in ```docker-compose.yml```.

Here is an example snippet from ```docker-compose.yml```:

        environment:
          KAFKA_CREATE_TOPICS: "Topic1:1:3,Topic2:1:1"

```Topic 1``` will have 1 partition and 3 replicas, ```Topic 2``` will have 1 partition and 1 replica.


##Tests
tests are just samples, could&should be improved 

##Tutorial

[https://github.com/fvigotti/docker-kafka](https://github.com/fvigotti/docker-kafka)


