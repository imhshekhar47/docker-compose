# Kafka Cluster

This cluster contains below clusters
#### Kafka-core-containers
- hs-zookeeper
- hs-broker-01
- hs-broker-02

#### Kafka confluent connector
- hs-connector

#### Elastic search
- hs-elsticsearch
- hs-kibana

## Connector 
### 1. Login to hs-connector
```bash
docker exec -it hs-connector bash
```
### 2. Elastic search Sink Connector
```bash
## List all the connectors
curl -X GET -i -H 'Accept:application/json' hs-connector:8083/connectors/

## Run this to delete the es-movie-sink connector if already running
curl -X DELETE -H 'Accept:application/json' 'hs-connector:8083/connectors/es-movie-sink'
curl -X POST -H 'Content-type:application/json' 'hs-connector:8083/connectors' -d '{
    "name" : "es-movie-sink",
    "config" : {
        "connector.class" : "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
        "tasks.max" : "1",
        "topics" : "movies,actors,movie-ratings,actor-ratings", 
        "connection.url" : "http://elasticsearch:9200",
        "type.name": "type.name=movie",
        "key.ignore" : "true",
        "schema.ignore" : "true",
        "key.converter.schemas.enable": "false",
        "key.converter": "org.apache.kafka.connect.storage.StringConverter",
        "value.converter.schemas.enable": "false",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "transforms": "routeTS",
        "transforms.routeTS.type": "org.apache.kafka.connect.transforms.TimestampRouter",
        "transforms.routeTS.topic.format": "${topic}-${timestamp}",
        "transforms.routeTS.timestamp.format": "yyyyMMdd"
    }
}'

## Check the status of es-movie-sink connector, fix and retry the above in sequence
curl -X GET -i -H 'Accept:application/json' hs-connector:8083/connectors/es-movie-sink/status
```

## Elasticsearch
## 1. Indexes
Check @ `http://localhost:9200/_cat/indices?v` if the indexes are getting created by the es-sink-connector. It should show below index.

    - movies
    - actors
    - movie-ratings
    - actor-ratings

    - movies-{YYYYMMDD}
    - actors-{YYYYMMDD}
    - movie-ratings-{YYYMMDD}
    - actor-ratings-{YYYYMMDD}



