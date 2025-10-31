# ARK: Survival Evolved Server - Modern Edition

> 🌍 [Versión en español disponible](README.md)

Modernized ARK: Survival Evolved dedicated server with **Ubuntu 22.04 LTS** and **Node.js 20 LTS**.

## Features

- ✅ **Ubuntu 22.04 LTS** - Stable base system, SteamCMD compatible
- ✅ **Node.js 20 LTS** - Modern Node.js version
- ✅ **SteamCMD** - Automatic installation and updates
- ✅ **RCON** - Remote server administration
- ✅ **Heartbeat Monitor** - Server health monitoring
- ✅ **Auto-save** - Automatic save every 15 minutes
- ✅ **Mod Support** - Automatic mod installation
- ✅ **Cluster Support** - Connect multiple servers
- ✅ **Data persistence** - Saves your progress

## Quick Start

```bash
# Download and run
docker pull b3lerofonte/ark-server:latest

# Using docker run
docker run -d \
  --name ark-server \
  -p 7777:7777/udp \
  -p 7778:7778/udp \
  -p 27015:27015/udp \
  -p 27020:27020 \
  -v ark-data:/steamcmd/ark \
  -e ARK_SESSION_NAME="My ARK Server" \
  -e ARK_ADMIN_PASSWORD="your_password_here" \
  b3lerofonte/ark-server:latest
```

## Using Docker Compose

```yaml
services:
  ark-server:
    image: b3lerofonte/ark-server:latest
    container_name: ark-server
    restart: unless-stopped
    ports:
      - "7777:7777/udp"    # Game port
      - "7778:7778/udp"    # Raw UDP socket
      - "27015:27015/udp"  # Query port
      - "27020:27020"      # RCON port
    volumes:
      - ark-data:/steamcmd/ark
    environment:
      ARK_SESSION_NAME: "My ARK Server"
      ARK_SERVER_PASSWORD: ""
      ARK_ADMIN_PASSWORD: "change_this_password"
      ARK_MAX_PLAYERS: "70"
      ARK_SERVER_MAP: "TheIsland"
      ARK_DIFFICULTY: "4.0"
      ARK_SERVER_PVE: "False"

volumes:
  ark-data:
```

Then run:
```bash
docker compose up -d
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ARK_SESSION_NAME` | Server name | "ARK Server Powered by Docker" |
| `ARK_SERVER_PASSWORD` | Password to play | "" (no password) |
| `ARK_ADMIN_PASSWORD` | Admin password | "changeme" |
| `ARK_MAX_PLAYERS` | Max players | "70" |
| `ARK_SERVER_MAP` | Map to use | "TheIsland" |
| `ARK_GAME_PORT` | Game port | "7777" |
| `ARK_QUERY_PORT` | Query port | "27015" |
| `ARK_RCON_PORT` | RCON port | "27020" |
| `ARK_DIFFICULTY` | Difficulty (0.0-10.0) | "4.0" |
| `ARK_SERVER_PVE` | PvE mode | "False" |
| `ARK_TAMING_SPEED_MULTIPLIER` | Taming speed | "1.0" |
| `ARK_HARVEST_AMOUNT_MULTIPLIER` | Resource amount | "1.0" |
| `ARK_XP_MULTIPLIER` | XP multiplier | "1.0" |
| `ARK_UPDATE_ON_START` | Update on start | "1" |

## Available Maps

### Free Maps
- `TheIsland` - Original map
- `TheCenter` - Varied biomes
- `Ragnarok` - Large map with desert and snow
- `Valguero` - Caves and abundant resources
- `CrystalIsles` - Crystals and special creatures
- `LostIsland` - Large tropical map
- `Fjordur` - Inspired by Norse mythology

### DLCs (Purchase required)
- `ScorchedEarth` - Desert
- `Aberration` - Underground
- `Extinction` - Post-apocalyptic
- `Genesis` - Simulation
- `Genesis2` - Space colony

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 7777 | UDP | Main game port |
| 7778 | UDP | Raw UDP socket |
| 27015 | UDP | Query port (Steam) |
| 27020 | TCP | RCON port |

## Volumes

- `/steamcmd/ark` - Persistent server data (maps, config, saves)

## First Run

On first startup, the server will:
1. Download and install SteamCMD
2. Download ARK server files (~23 GB)
3. Generate the selected map
4. Start the server

**This can take 20-40 minutes** depending on your connection.

### Server Status

The server includes monitoring applications that start automatically:
- **Heartbeat Monitor**: Checks server health every minute
- **Scheduler**: Auto-save every 15 minutes
- **RCON**: Available for remote administration

## Administration

### View logs in real-time

```bash
docker compose logs -f ark-server
```

### Access RCON

```bash
# Enter container
docker exec -it ark-server bash

# Common RCON commands
rcon ListPlayers          # List connected players
rcon SaveWorld            # Save the world
rcon "ServerChat Hello"   # Send message to chat
rcon DoExit               # Shutdown server
```

### Verify Server Status

```bash
# Check if server is running
docker exec ark-server bash -c "ps aux | grep ShooterGameServer | grep -v grep"

# View open ports
docker ps --filter name=ark-server --format "table {{.Names}}\t{{.Ports}}"

# Test RCON
docker exec ark-server rcon ListPlayers
```

### Restart server

```bash
docker compose restart ark-server
```

### Stop server

```bash
docker compose down
```

## Mod Installation

To install Steam Workshop mods:

```yaml
environment:
  - ARK_MODS=731604991,889745138,895711211
```

Mods will be downloaded automatically on startup.

## Cluster Configuration

To connect multiple servers:

```yaml
environment:
  - ARK_CLUSTER_ID=my-cluster
  - ARK_CLUSTER_DIR_OVERRIDE=/ark-cluster

volumes:
  - ark-cluster:/ark-cluster
```

Use the same `ARK_CLUSTER_ID` on all servers.

## Recommended Resources

### Minimum
- **CPU**: 4 cores
- **RAM**: 8 GB
- **Disk**: 50 GB
- **Network**: Stable connection with open ports

### Recommended
- **CPU**: 6+ cores
- **RAM**: 12+ GB
- **Disk**: 100+ GB SSD
- **Network**: Stable connection with open ports

## Base Image

This image is built on top of:
- **b3lerofonte/base:nodejs-20-steamcmd-ubuntu-22.04**
- Repository: [base-2025](https://github.com/AngelMartinezDevops/base-2025)

## Repository

Source code: [ark-server-2025](https://github.com/AngelMartinezDevops/ark-server-2025)

## License

MIT License - See LICENSE.md

## Author

**b3lerofonte**
- GitHub: [@AngelMartinezDevops](https://github.com/AngelMartinezDevops)
- Docker Hub: [b3lerofonte](https://hub.docker.com/u/b3lerofonte)
- Email: angel200391@gmail.com

## Credits

Based on the base image:
- [b3lerofonte/base](https://github.com/AngelMartinezDevops/base-2025)

Inspired by:
- [thmhoag/arkserver](https://github.com/thmhoag/arkserver)

## Support

If you encounter any issues:
1. Check the logs: `docker compose logs -f ark-server`
2. Verify ports are open
3. Ensure you have enough disk space
4. Check Docker and Docker Compose versions

For bugs and feature requests, open an issue on GitHub.

---

**Note**: This is an unofficial independent image. Not affiliated with Studio Wildcard or Snail Games.

