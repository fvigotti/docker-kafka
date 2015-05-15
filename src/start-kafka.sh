#!/bin/bash

echo 'kafka base configuration : '
echo '$KAFKA_ADVERTISED_PORT = '$KAFKA_ADVERTISED_PORT
echo '$KAFKA_BROKER_ID = '$KAFKA_BROKER_ID
echo '$KAFKA_LOG_DIRS = '$KAFKA_LOG_DIRS
echo '$KAFKA_ZOOKEEPER_CONNECT = '$KAFKA_ZOOKEEPER_CONNECT
echo '$KAFKA_HEAP_OPTS = '$KAFKA_HEAP_OPTS

if [[ -z "$KAFKA_ADVERTISED_PORT" ]]; then
    export KAFKA_ADVERTISED_PORT=9092
fi
if [[ -z "$KAFKA_BROKER_ID" ]]; then
    echo 'ERROR, $KAFKA_BROKER_ID not configured'
    exit 1
fi

if [[ -z "$KAFKA_LOG_DIRS" ]]; then
    export KAFKA_LOG_DIRS="/kafka/kafka-logs-$KAFKA_BROKER_ID"
    echo '$KAFKA_LOG_DIRS defaulted to -> '$KAFKA_LOG_DIRS
fi

if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then
    export KAFKA_ZOOKEEPER_CONNECT=$(env | grep ZK.*PORT_2181_TCP= | sed -e 's|.*tcp://||' | paste -sd ,)
    echo '$KAFKA_ZOOKEEPER_CONNECT defaulted from env ZK host to -> '$KAFKA_ZOOKEEPER_CONNECT
fi

#if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
#    sed -r -i "s/^(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
#    unset KAFKA_HEAP_OPTS
#fi

for VAR in `env`
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME ]]; then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)$kafka_name=" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${!env_var}@g" $KAFKA_HOME/config/server.properties #note that no config values may contain an '@' char
    else
        echo "$kafka_name=${!env_var}" >> $KAFKA_HOME/config/server.properties
    fi
  fi
done

KAFKA_SERVER_PID=""

stop_kafka(){

if [[ -z "$KAFKA_SERVER_PID" ]]; then
    echo 'kafka pid not set, exiting.. '
    exit 0
fi
kill -9 $KAFKA_SERVER_PID
wait $KAFKA_SERVER_PID
echo 'kafka closed, -wait- exit status ='$?

exit 0
}

trapped_exit() {
# Perform program exit housekeeping
echo '[TRAPPED] '$1' closing kafka pid ['$KAFKA_SERVER_PID']';
stop_kafka
exit 0
}

# capture signals
trap "trapped_exit" SIGHUP
trap "trapped_exit" SIGINT
trap "trapped_exit" SIGTERM
trap "trapped_exit" SIGKILL


$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &
KAFKA_SERVER_PID=$!

# the wile loop should be limited to avoid infinite waiting for kafka to start in case of error in configuration
#while netstat -lnt | awk '$4 ~ /:9092$/ {exit 1}'; do sleep 1; done
#
#if [[ -n $KAFKA_CREATE_TOPICS ]]; then
#    IFS=','; for topicToCreate in $KAFKA_CREATE_TOPICS; do
#        IFS=':' read -a topicConfig <<< "$topicToCreate"
#        $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZOOKEEPER_CONNECT --replication-factor ${topicConfig[2]} --partition ${topicConfig[1]} --topic "${topicConfig[0]}"
#    done
#fi
#
wait $KAFKA_SERVER_PID