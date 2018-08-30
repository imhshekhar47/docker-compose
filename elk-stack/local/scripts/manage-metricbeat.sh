#!/bin/bash
METRICBEAT_VERSION=6.4.0

yum_install() {
    artifact_name="metricbeat-${METRICBEAT_VERSION}-x86_64.rpm"
    echo "Installing ${artifact_name}"
    curl -L -O "https://artifacts.elastic.co/downloads/beats/metricbeat/${artifact_name}"
    rpm -iv "${artifact_name}"

    postinstall_config
}

deb_install() {
    artifact_name="metricbeat-${METRICBEAT_VERSION}-amd64.deb"
    echo "Installing ${artifact_name}"
    curl -L -O "https://artifacts.elastic.co/downloads/beats/metricbeat/${artifact_name}"
    dpkg -i "${artifact_name}"
    rm "${artifact_name}"

    postinstall_config
}


postinstall_config() {
    mkdir -p /var/log/beats
    mv /etc/metricbeat/metricbeat.yml /etc/metricbeat/metricbeat.yml.original
    cat >/etc/metricbeat/metricbeat.yml <<EOL
metricbeat.config.modules:
    path: /usr/share/metricbeat/modules.d/*.yml

setup:
    kibana:
        host: "kibana:5601"
    template:
        name: "metricbeat-${HOSTNAME}"
        pattern: "metricbeat-${HOSTNAME}-*"

output.elasticsearch:
    hosts: ["elasticsearch:9200"]
    index: "metricbeat-${HOSTNAME}-%{+yyyy.MM.dd}"

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
    which metricbeat > /dev/null 
    if [ $? -eq 0 ]; then
        echo "[INFO] Already install"
        metricbeat version
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
    metricbeat setup
}

run_test() {
    echo "[INFO] Check config"
    metricbeat test config

    echo "[INFO] Check output"
    metricbeat test config

    echo "[INFO] Check modules"
    metricbeat modules list
}

is_running() {
    pid=`pgrep -f "metricbeat.*run$"`
    if [ -z "${pid}" ]; then 
        return 3
    else
        return 0
    fi
}

run_metrics() {
    is_running
    if [ $? -eq 0 ]; then
        pid=`pgrep -f "metricbeat.*run$"`
        echo "[WARN] metricbeat is already running (pid $pid)"
    else
        echo "[INFO] Starting metricbeat"
        metricbeat run &
        echo "[INFO] Started metricbeat (pid $!)"
    fi
}

run_stop() {
    is_running
    if [ $? -eq 0 ]; then
        pid=`pgrep -f "metricbeat.*run$"`
        echo "[INFO] Stopping ${pid}"
        kill -9 $pid > /dev/null
        if [ $? -eq 0 ]; then
            echo "[INFO] Stopped metricbeat"
        fi
    else
        echo "[INFO] metricbeat was not running"
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