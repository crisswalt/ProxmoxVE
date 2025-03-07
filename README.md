# Proxmox VE Helper-Scripts

Este repositorio contiene scripts automatizados para la instalación y configuración de aplicaciones en contenedores LXC dentro de Proxmox VE.

## 📌 Descripción
Los scripts están diseñados para facilitar la implementación de servicios en entornos virtualizados de manera eficiente y segura. Cada script sigue una estructura estándar basada en la comunidad de **Proxmox VE Helper-Scripts**, permitiendo una rápida implementación y actualización de los servicios.

## 🚀 Scripts Disponibles

### Kafka LXC
- **Descripción:** Implementa Apache Kafka con Zookeeper en un contenedor LXC.
- **Requisitos mínimos:**
  - CPU: 2
  - RAM: 2GB
  - Disco: 10GB
  - OS: Debian 12
- **Instalación:**
  ```bash
  bash "$(wget -qLO - https://raw.githubusercontent.com/crisswalt/ProxmoxVE/main/ct/kafka.sh)"
  ```
- **Acceso:** Kafka estará disponible en `http://<IP_DEL_CONTENEDOR>:9092`.


## 🔄 Actualización de los Scripts
Cada script incluye una función de actualización automática para mantener las aplicaciones al día sin necesidad de reinstalar el contenedor.

## 🤝 Contribuciones
Las contribuciones son bienvenidas. Si deseas mejorar o agregar más scripts, por favor realiza un **fork** del repositorio y envía un **pull request**.

## 📜 Licencia
Este proyecto está bajo la licencia **MIT**.

---

📢 **Nota:** Se recomienda ejecutar estos scripts en un entorno de pruebas antes de utilizarlos en producción.

