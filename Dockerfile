# Dockerfile para Servidor ARK: Survival Evolved
# Usa la imagen base con Ubuntu 22.04 + Node.js 20 + SteamCMD

FROM b3lerofonte/base:nodejs-20-steamcmd-ubuntu-22.04

LABEL maintainer="b3lerofonte"

# ============================================
# VARIABLES DE ENTORNO DEL SERVIDOR ARK
# ============================================
ENV ARK_SESSION_NAME="ARK Server Powered by Docker"
ENV ARK_SERVER_PASSWORD=""
ENV ARK_ADMIN_PASSWORD="changeme"
ENV ARK_MAX_PLAYERS="70"
ENV ARK_SERVER_MAP="TheIsland"
ENV ARK_MODS=""
ENV ARK_MULTIHOME=""
ENV ARK_GAME_PORT="7777"
ENV ARK_QUERY_PORT="27015"
ENV ARK_RAW_SOCKETS_PORT="7778"
ENV ARK_RCON_PORT="27020"
ENV ARK_RCON_ENABLE="True"
ENV ARK_DIFFICULTY="4.0"
ENV ARK_SERVER_PVE="False"
ENV ARK_ENABLE_PVP_GAMMA="False"
ENV ARK_DISABLE_DINO_DECAY="False"
ENV ARK_DISABLE_STRUCTURE_DECAY="False"
ENV ARK_ALLOW_FLYER_SPEED_LEVELING="False"
ENV ARK_CLUSTER_ID=""
ENV ARK_CLUSTER_DIR_OVERRIDE=""

# Configuración de recursos
ENV ARK_SERVER_CULTURE="en"
ENV ARK_SERVER_CROSSPLAY="False"
ENV ARK_BATTLEYE="True"

# Configuración de tasas
ENV ARK_TAMING_SPEED_MULTIPLIER="1.0"
ENV ARK_HARVEST_AMOUNT_MULTIPLIER="1.0"
ENV ARK_XP_MULTIPLIER="1.0"

# Opciones de actualización
ENV ARK_UPDATE_ON_START="1"
ENV ARK_BACKUP_ON_STOP="1"
ENV ARK_NOTIFY_ON_UPDATE="0"
ENV ARK_WARN_ON_STOP="0"

# Variables adicionales
USER root

# ============================================
# CONFIGURAR NPM PARA REGISTRY PÚBLICO
# ============================================
RUN npm config set registry https://registry.npmjs.org/

# ============================================
# INSTALAR APLICACIONES NODE.JS
# ============================================

# Shutdown app
COPY shutdown_app/ /app/shutdown_app/
WORKDIR /app/shutdown_app
RUN rm -f .npmrc package-lock.json && \
    npm install --registry=https://registry.npmjs.org/

# Restart app
COPY restart_app/ /app/restart_app/
WORKDIR /app/restart_app
RUN rm -f .npmrc package-lock.json && \
    npm install --registry=https://registry.npmjs.org/

# Scheduler app
COPY scheduler_app/ /app/scheduler_app/
WORKDIR /app/scheduler_app
RUN rm -f .npmrc package-lock.json && \
    npm install --registry=https://registry.npmjs.org/

# Heartbeat app
COPY heartbeat_app/ /app/heartbeat_app/
WORKDIR /app/heartbeat_app
RUN rm -f .npmrc package-lock.json && \
    npm install --registry=https://registry.npmjs.org/

# RCON app
COPY rcon_app/ /app/rcon_app/
WORKDIR /app/rcon_app
RUN rm -f .npmrc package-lock.json && \
    npm install --registry=https://registry.npmjs.org/
RUN ln -s /app/rcon_app/app.js /usr/bin/rcon

# ============================================
# COPIAR SCRIPTS Y CONFIGURACIÓN
# ============================================

# Scripts principales
COPY start_ark.sh /app/start_ark.sh
COPY update_check.sh /app/update_check.sh
COPY install.txt /app/install.txt

# Convertir finales de línea de Windows a Unix
RUN sed -i 's/\r$//' /app/*.sh

# ============================================
# CONFIGURAR PERMISOS
# ============================================
RUN chown -R 1000:1000 \
    /steamcmd \
    /app && \
    chmod +x /app/*.sh

# ============================================
# EXPONER PUERTOS ARK
# ============================================
EXPOSE 7777/udp
EXPOSE 7778/udp
EXPOSE 27015/udp
EXPOSE 27020/tcp

# ============================================
# VOLÚMENES
# ============================================
VOLUME ["/steamcmd/ark"]

# ============================================
# INICIO
# ============================================
WORKDIR /app

# Cambiar a usuario docker
USER docker

# Script de inicio
CMD ["/bin/bash", "/app/start_ark.sh"]

