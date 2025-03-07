#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2025
# Autor: Cristián Walter Carrasco Vargas
# Licencia: MIT
# Fuente: https://kafka.apache.org/

APP="Kafka"
var_tags="message-broker"
var_cpu="2"
var_ram="2048"
var_disk="10"
var_os="debian"
var_version="12"
var_unprivileged="1"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -f /opt/kafka/bin/kafka-server-start.sh ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  RELEASE=$(curl -s https://downloads.apache.org/kafka/ | grep -oP 'kafka-\K[\d.]+(?=/)' | sort -V | tail -n 1)
  if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt 2>/dev/null)" ]]; then
    msg_info "Stopping ${APP}"
    systemctl stop kafka zookeeper
    msg_ok "${APP} Stopped"
    
    msg_info "Updating ${APP} to ${RELEASE}"
    wget -q https://downloads.apache.org/kafka/${RELEASE}/kafka_${RELEASE}.tgz -O /tmp/kafka.tgz
    tar -xzf /tmp/kafka.tgz -C /opt/
    mv /opt/kafka_${RELEASE} /opt/kafka
    rm -f /tmp/kafka.tgz
    echo "${RELEASE}" > /opt/${APP}_version.txt
    msg_ok "Updated ${APP}"

    msg_info "Starting ${APP}"
    systemctl start zookeeper kafka
    msg_ok "Started ${APP}"
  else
    msg_ok "No update required. ${APP} is already at ${RELEASE}"
  fi
  exit
}

start
build_container

msg_info "Installing Java"
apt update -qq
apt install -y openjdk-17-jre-headless
msg_ok "Java Installed"

msg_info "Downloading and Installing Kafka"
RELEASE=$(curl -s https://downloads.apache.org/kafka/ | grep -oP 'kafka-\K[\d.]+(?=/)' | sort -V | tail -n 1)
wget -q https://downloads.apache.org/kafka/${RELEASE}/kafka_${RELEASE}.tgz -O /tmp/kafka.tgz
tar -xzf /tmp/kafka.tgz -C /opt/
mv /opt/kafka_${RELEASE} /opt/kafka
rm -f /tmp/kafka.tgz
msg_ok "Kafka Installed"

echo "${RELEASE}" > /opt/${APP}_version.txt

msg_info "Configuring Zookeeper"
cat <<EOF > /opt/kafka/config/zookeeper.properties
clientPort=2181
dataDir=/var/lib/zookeeper
tickTime=2000
EOF
mkdir -p /var/lib/zookeeper
msg_ok "Zookeeper Configured"

msg_info "Configuring Kafka"
cat <<EOF > /opt/kafka/config/server.properties
broker.id=1
listeners=PLAINTEXT://:9092
log.dirs=/var/lib/kafka-logs
zookeeper.connect=localhost:2181
num.partitions=1
log.retention.hours=168
default.replication.factor=1
EOF
mkdir -p /var/lib/kafka-logs
msg_ok "Kafka Configured"

msg_info "Creating systemd services"
cat <<EOF > /etc/systemd/system/zookeeper.service
[Unit]
Description=Apache Zookeeper server
After=network.target

[Service]
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/kafka.service
[Unit]
Description=Apache Kafka server
After=zookeeper.service

[Service]
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now zookeeper kafka
msg_ok "Services Created and Started"

description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access Kafka using:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:9092${CL}"
