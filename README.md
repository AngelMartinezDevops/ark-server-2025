# ARK: Survival Evolved Server - Modern Edition

> 🌍 [English version available](README_EN.md)

Servidor dedicado de ARK: Survival Evolved modernizado con **Ubuntu 22.04 LTS** y **Node.js 20 LTS**.

## Características

- ✅ **Ubuntu 22.04 LTS** - Sistema base estable y compatible con SteamCMD
- ✅ **Node.js 20 LTS** - Versión moderna de Node.js
- ✅ **SteamCMD** - Instalación y actualización automática
- ✅ **RCON** - Administración remota del servidor
- ✅ **Heartbeat Monitor** - Monitoreo de salud del servidor
- ✅ **Auto-save** - Guardado automático cada 15 minutos
- ✅ **Soporte para Mods** - Instalación automática de mods
- ✅ **Soporte para Clusters** - Conecta múltiples servidores
- ✅ **Persistencia de datos** - Guarda tu progreso

## Inicio Rápido

```bash
# Descargar y ejecutar
docker pull b3lerofonte/ark-server:latest

# Usando docker run
docker run -d \
  --name ark-server \
  -p 7777:7777/udp \
  -p 7778:7778/udp \
  -p 27015:27015/udp \
  -p 27020:27020 \
  -v ark-data:/steamcmd/ark \
  -e ARK_SESSION_NAME="Mi Servidor ARK" \
  -e ARK_ADMIN_PASSWORD="tu_password_aqui" \
  b3lerofonte/ark-server:latest
```

## Usando Docker Compose

```yaml
services:
  ark-server:
    image: b3lerofonte/ark-server:latest
    container_name: ark-server
    restart: unless-stopped
    ports:
      - "7777:7777/udp"    # Puerto de juego
      - "7778:7778/udp"    # Raw UDP socket
      - "27015:27015/udp"  # Query port
      - "27020:27020"      # RCON port
    volumes:
      - ark-data:/steamcmd/ark
    environment:
      ARK_SESSION_NAME: "Mi Servidor ARK"
      ARK_SERVER_PASSWORD: ""
      ARK_ADMIN_PASSWORD: "cambiar_esta_password"
      ARK_MAX_PLAYERS: "70"
      ARK_SERVER_MAP: "TheIsland"
      ARK_DIFFICULTY: "4.0"
      ARK_SERVER_PVE: "False"

volumes:
  ark-data:
```

Luego ejecuta:
```bash
docker compose up -d
```

## Variables de Entorno

| Variable | Descripción | Por Defecto |
|----------|-------------|-------------|
| `ARK_SESSION_NAME` | Nombre del servidor | "ARK Server Powered by Docker" |
| `ARK_SERVER_PASSWORD` | Password para jugar | "" (sin password) |
| `ARK_ADMIN_PASSWORD` | Password de administrador | "changeme" |
| `ARK_MAX_PLAYERS` | Jugadores máximos | "70" |
| `ARK_SERVER_MAP` | Mapa a usar | "TheIsland" |
| `ARK_GAME_PORT` | Puerto de juego | "7777" |
| `ARK_QUERY_PORT` | Puerto de query | "27015" |
| `ARK_RCON_PORT` | Puerto RCON | "27020" |
| `ARK_DIFFICULTY` | Dificultad (0.0-10.0) | "4.0" |
| `ARK_SERVER_PVE` | Modo PvE | "False" |
| `ARK_TAMING_SPEED_MULTIPLIER` | Velocidad de domesticación | "1.0" |
| `ARK_HARVEST_AMOUNT_MULTIPLIER` | Cantidad de recursos | "1.0" |
| `ARK_XP_MULTIPLIER` | Multiplicador de XP | "1.0" |
| `ARK_UPDATE_ON_START` | Actualizar al iniciar | "1" |

## Mapas Disponibles

### Mapas Gratuitos
- `TheIsland` - Mapa original
- `TheCenter` - Biomas variados
- `Ragnarok` - Gran mapa con desierto y nieve
- `Valguero` - Cuevas y recursos abundantes
- `CrystalIsles` - Cristales y criaturas especiales
- `LostIsland` - Mapa tropical grande
- `Fjordur` - Inspirado en mitología nórdica

### DLCs (Requieren compra)
- `ScorchedEarth` - Desierto
- `Aberration` - Subterráneo
- `Extinction` - Post-apocalíptico
- `Genesis` - Simulación
- `Genesis2` - Colonia espacial

## Puertos

| Puerto | Protocolo | Descripción |
|--------|-----------|-------------|
| 7777 | UDP | Puerto de juego principal |
| 7778 | UDP | Raw UDP socket |
| 27015 | UDP | Query port (Steam) |
| 27020 | TCP | RCON port |

## Volúmenes

- `/steamcmd/ark` - Datos persistentes del servidor (mapas, configuración, guardados)

## Primera Ejecución

En el primer arranque, el servidor:
1. Descargará e instalará SteamCMD
2. Descargará los archivos del servidor ARK (~10-15 GB)
3. Generará el mapa seleccionado
4. Iniciará el servidor

**Esto puede tardar 20-30 minutos** dependiendo de tu conexión.

## Administración

### Ver logs en tiempo real

```bash
docker compose logs -f ark-server
```

### Acceder a RCON

```bash
# Entrar al contenedor
docker exec -it ark-server bash

# Comandos RCON comunes
rcon ListPlayers
rcon SaveWorld
rcon "ServerChat Hola a todos"
rcon DoExit
```

### Reiniciar servidor

```bash
docker compose restart ark-server
```

### Detener servidor

```bash
docker compose down
```

## Instalación de Mods

Para instalar mods de Steam Workshop:

```yaml
environment:
  - ARK_MODS=731604991,889745138,895711211
```

Los mods se descargarán automáticamente al iniciar.

## Configuración de Cluster

Para conectar múltiples servidores:

```yaml
environment:
  - ARK_CLUSTER_ID=mi-cluster
  - ARK_CLUSTER_DIR_OVERRIDE=/ark-cluster

volumes:
  - ark-cluster:/ark-cluster
```

Usa el mismo `ARK_CLUSTER_ID` en todos los servidores.

## Recursos Recomendados

### Mínimo
- **CPU**: 4 cores
- **RAM**: 8 GB
- **Disco**: 50 GB
- **Red**: Conexión estable con puertos abiertos

### Recomendado
- **CPU**: 6+ cores
- **RAM**: 12+ GB
- **Disco**: 100+ GB SSD
- **Red**: Conexión estable con puertos abiertos

## Imagen Base

Esta imagen está construida sobre:
- **b3lerofonte/base:nodejs-20-steamcmd-ubuntu-22.04**
- Repositorio: [base-2025](https://github.com/AngelMartinezDevops/base-2025)

## Repositorio

Código fuente: [ark-server-2025](https://github.com/AngelMartinezDevops/ark-server-2025)

## Soporte

Si encuentras algún problema, por favor abre un issue en GitHub.

## Licencia

MIT License - Libre para uso personal y comercial.

---

**Nota**: Esta es una imagen independiente no oficial. No está afiliada con Studio Wildcard o Snail Games.

