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
  echo https://api.github.com/repos/apache/kafka/releases/latest
  RELEASE=$(curl -s https://downloads.apache.org/kafka/ | grep 'folder' | awk -F '>' '{print $3}' | sed 's/\/.*//' | sort -V | tail -n 1)
  if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt 2>/dev/null)" ]]; then
    msg_info "Stopping ${APP}"
    systemctl stop kafka zookeeper
    msg_ok "${APP} Stopped"
    
    msg_info "Updating ${APP} to ${RELEASE}"

    DIST=$(curl -s https://downloads.apache.org/kafka/${RELEASE}/ | grep compressed | grep ${RELEASE}.tgz | awk -F '"' '{print $6}' | sort -V | tail -n 1 | sed 's/\.tgz//')

    wget -q https://downloads.apache.org/kafka/${RELEASE}/${DIST}.tgz -O /tmp/${DIST}.tgz
    tar -xzf /tmp/${DIST}.tgz -C /opt/
    ln -s /opt/${DIST} /opt/kafka
    rm -f /tmp/${DIST}.tgz 
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
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access Kafka using:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:9092${CL}"
