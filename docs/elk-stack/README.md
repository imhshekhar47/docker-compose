# Overview
<img src="./images/icon-elk-e.svg" width=96px />
<img src="./images/icon-elk-l.svg" width=96px />
<img src="./images/icon-elk-k.svg" width=96px />

This is a setup of elk stack using docker.

# Prerequisite
### 1. Setup Network
```bash
docker network create dbnet
```
### 2. Setup Oracel DB (Optional)
You need an oracle database to monitor it's, perfomance metrics. For which you can setup containerized oracle db, or can skip if you already have extenal db instance running.
```
docker pull sath89/oracle-12c
docker run -d \
    --name=oracledb \
    --hostname=oracledb \
    -p 1521:1521 \
    -v "${PWD}/local":/local:ro \
    sath89/oracle-12c:latest
    
docker network connect dbnet oracledb
```

# Start elk-stack
```
docker-compose -f elk-compose.yml up --build
```
Once the stack is up and running you can access
- kibana: `http://localhost:5601`.
- elasticsearch: `http://localhost:9002`


# Stop elk-stack
```bash
docker-compose -f elk-compose.yml down
```


# Refernece
- https://www.docker.elastic.co/
- https://www.elastic.co/blog/visualising-oracle-performance-data-with-the-elastic-stack


[elk-stack]: wiki/images/icon-elk.svg "elk stack"
[elk-e]: wiki/images/icon-elk-e.svg "elasticsearch"
[elk-l]: wiki/images/icon-elk-l.svg "logstash"
[elk-k]: wiki/images/icon-elk-k.svg "kibana"
[elk-b]: wiki/images/icon-elk-b.svg "beats"
