#!/bin/bash

FILEBEAT_VERSION=6.4.0

yum_install() {
    artifact_name="filebeat-${FILEBEAT_VERSION}-x86_64.rpm"
    echo "Installing ${artifact_name}"
    curl -L -O "https://artifacts.elastic.co/downloads/beats/filebeat/${artifact_name}"
    rpm -iv "${artifact_name}"

    postinstall_config
}

deb_install() {
    artifact_name="filebeat-${FILEBEAT_VERSION}-amd64.deb"
    echo "Installing ${artifact_name}"
    curl -L -O "https://artifacts.elastic.co/downloads/beats/filebeat/${artifact_name}"
    dpkg -i "${artifact_name}"
    rm "${artifact_name}"

    postinstall_config
}


postinstall_config() {
    mkdir -p /var/log/beats
    mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.original
    cat >/etc/filebeat/filebeat.yml <<EOL
filebeat.prospectors:
    - type: log
      paths: 
        - /var/log/oracle/*.log
      document_type: orametrics
      fields:
        type: orametrics
        document_type: orametrics

setup:
    kibana:
        host: "kibana:5601"
        
output.logstash:
    hosts: ["logstash:5044"]

EOL
}

help() {
    echo "$0 [help | install | setup | reset | test | start | stop ]"
}

run_reset() {
    is_running
    if [ $? -eq 0 ]; then
        run_stop
    fi
    postinstall_config
}

run_install() {
    which filebeat > /dev/null 
    if [ $? -eq 0 ]; then
        echo "[INFO] Already install"
        filebeat version
    else
        which yum > /dev/null 
        if [ $? -eq 0 ]; then
            yum_install
        else
            deb_install
        fi
    fi
}

run_setup() {
    echo "[INFO] Setup kibana"
    filebeat setup --dashboards
}

run_test() {
    echo "[INFO] Check config"
    filebeat test config

    echo "[INFO] Check output"
    filebeat test output
}

is_running() {
    pid=`pgrep -f "filebeat.*run$"`
    #echo $pid
    if [ -z "${pid}" ]; then 
        #echo "Not running"
        return 3
    else
        #echo "Running $pid"
        return 0
    fi
}

run_metrics() {
    is_running
    if [ $? -eq 0 ]; then
        pid=`pgrep -f "filebeat.*run$"`
        echo "[WARN] filebeat is already running (pid $pid)"
    else
        echo "[INFO] Starting filebeat"
        filebeat run &
        echo "[INFO] Started filebeat (pid $!)"
    fi
}

run_stop() {
    is_running
    if [ $? -eq 0 ]; then
        pid=`pgrep -f "filebeat.*run"`
        echo "[INFO] Stopping ${pid}"
        kill -9 $pid 
        if [ $? -eq 0 ]; then
            echo "[INFO] Stopped filebeat"
        fi
    else
        echo "[INFO] filebeat was not running"
    fi
}

case $1 in
    "install")
        run_install
        ;;
    "setup")
        run_setup
        ;;
    "reset")
        run_reset
        ;;
    "test")
        run_test
        ;;
    "start")
        run_metrics
        ;;
    "stop")
        run_stop
        ;;
    *)
        help
        ;;
esac

exit $?