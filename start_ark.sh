#!/bin/bash
# Script de inicio para ARK: Survival Evolved Server
# Basado en el sistema de rust-server-2025

set -e

echo "=========================================="
echo "ARK: Survival Evolved Server - Docker"
echo "=========================================="
echo ""

# Directorios
ARK_DIR="/steamcmd/ark"
STEAMCMD_DIR="/steamcmd"
APP_DIR="/app"

# App ID de ARK Dedicated Server
ARK_APP_ID="376030"

# Arreglar permisos del directorio de ARK antes de instalar
if [ -d "/steamcmd/ark" ]; then
    chown -R docker:docker /steamcmd/ark
fi

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Función para instalar/actualizar ARK
install_or_update_ark() {
    log "Verificando instalación de ARK..."
    
    if [ "${ARK_UPDATE_ON_START}" = "1" ]; then
        log "Actualizando servidor ARK..."
        su -s /bin/bash -c "cd ${STEAMCMD_DIR} && ./steamcmd.sh +force_install_dir ${ARK_DIR} +login anonymous +app_update ${ARK_APP_ID} +quit" docker
        log "Actualización completada."
    else
        # Solo instalar si no existe
        if [ ! -f "${ARK_DIR}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
            log "Instalando servidor ARK por primera vez..."
            su -s /bin/bash -c "cd ${STEAMCMD_DIR} && ./steamcmd.sh +force_install_dir ${ARK_DIR} +login anonymous +app_update ${ARK_APP_ID} validate +quit" docker
            log "Instalación completada."
        else
            log "Servidor ARK ya está instalado. Saltando actualización."
        fi
    fi
}

# Función para generar configuración
generate_config() {
    log "Generando configuración del servidor..."
    
    CONFIG_DIR="${ARK_DIR}/ShooterGame/Saved/Config/LinuxServer"
    GAME_INI="${CONFIG_DIR}/Game.ini"
    GAMEUSERSETTINGS_INI="${CONFIG_DIR}/GameUserSettings.ini"
    
    # Crear directorios si no existen
    mkdir -p "${CONFIG_DIR}"
    mkdir -p "${ARK_DIR}/ShooterGame/Saved/SavedArks"
    
    # Crear Game.ini básico si no existe
    if [ ! -f "${GAME_INI}" ]; then
        cat > "${GAME_INI}" << EOF
[/Script/ShooterGame.ShooterGameMode]
bDisableFriendlyFire=False
bPvEDisableFriendlyFire=False
bDisableLootCrates=False
MaxNumberOfPlayersInTribe=0
EOF
        log "Game.ini creado."
    fi
    
    # Crear GameUserSettings.ini
    cat > "${GAMEUSERSETTINGS_INI}" << EOF
[ServerSettings]
ServerPassword=${ARK_SERVER_PASSWORD}
ServerAdminPassword=${ARK_ADMIN_PASSWORD}
MaxPlayers=${ARK_MAX_PLAYERS}
DifficultyOffset=${ARK_DIFFICULTY}
ServerPVE=${ARK_SERVER_PVE}
ServerCrosshair=${ARK_ENABLE_PVP_GAMMA}
ServerHardcore=False
GlobalVoiceChat=False
ProximityChat=False
AllowThirdPersonPlayer=True
AlwaysNotifyPlayerLeft=True
DontAlwaysNotifyPlayerJoined=True
ShowMapPlayerLocation=True
EnablePVPGamma=${ARK_ENABLE_PVP_GAMMA}
DisableStructureDecayPvE=${ARK_DISABLE_STRUCTURE_DECAY}
AllowFlyerCarryPvE=True
TamingSpeedMultiplier=${ARK_TAMING_SPEED_MULTIPLIER}
HarvestAmountMultiplier=${ARK_HARVEST_AMOUNT_MULTIPLIER}
XPMultiplier=${ARK_XP_MULTIPLIER}
AllowFlyerSpeedLeveling=${ARK_ALLOW_FLYER_SPEED_LEVELING}

[/Script/ShooterGame.ShooterGameUserSettings]
MasterAudioVolume=1.000000
MusicAudioVolume=1.000000
SFXAudioVolume=1.000000
VoiceAudioVolume=1.000000
SoundUIAudioVolume=1.000000
CharacterAudioVolume=1.000000
bSoundUIAudioVolumeEnabled=True
bMuteVoiceChat=False
UIScaling=1.000000
UIQuickbarScaling=1.000000
CameraShakeScale=1.000000
bFirstPersonWithHands=True
bThirdPersonPlayer=False
bShowStatusNotificationMessages=True
TrueSkyQuality=0.270000
FOVMultiplier=1.000000
GroundClutterDensity=1.000000
bFilmGrain=False
bMotionBlur=True
bUseVSync=False
bUseDFAO=False
bUseSSAO=False
bShowChatBox=True
bCameraViewBob=True
bInvertLookY=False
bFloatingNames=True
bChatBubbles=True
bHideServerInfo=False
bJoinNotifications=False
bCraftablesShowAllItems=False
LookLeftRightSensitivity=1.000000
LookUpDownSensitivity=1.000000
GraphicsQuality=1
ActiveLingeringWorldTiles=10
ClientNetQuality=3
LastServerSearchType=0
LastServerSort=2
LastPVESearchType=-1
LastDLCTypeFilter=-1
LastServerSortAsc=True
LastAutoFavorite=True
LastServerFilter=
bDisableMenuTransitions=False
bEnableInventoryItemTooltips=True
bRemoteInventoryItemTooltips=False
bNoTooltipDelay=False
LocalItemSortType=0
LocalCraftingSortType=0
RemoteItemSortType=0
VersionMetaTag=1
ShowExplorerNoteSubtitles=False
DisableMenuMusic=False
DisableDefaultCharacterItems=False
bHideFloatingPlayerNames=False
bHideGamepadItemSelectionModifier=False
bToggleToTalk=False
HighQualityMaterials=True
HighQualitySurfaces=True
bTemperatureF=False
bDisableTorporEffect=False
bChatShowSteamName=False
bChatShowTribeName=True
bReverseTribeLogOrder=False
EmoteKeyBind1=0
EmoteKeyBind2=0
bNoBloodEffects=False
bLowQualityVFX=False
bSpectatorManualFloatingNames=False
bSuppressAdminIcon=False
bUseSimpleDistanceMovement=False
bDisableMeleeCameraSwingAnims=False
bPreventInventoryOpeningSounds=False
bPreventHitMarkers=False
bPreventCrosshair=False
bPreventColorizedItemNames=False
bHighQualityLODs=True
bExtraLevelStreamingDistance=False
bEnableColorGrading=True
DOFSettingInterpTime=0.000000
bDisableBloom=False
bDisableLightShafts=False
bUseLowQualityLevelStreaming=True
bForceNoMovementBlur=False
bUseOldThirdPersonCameraTrace=False
bUseOldThirdPersonCameraOffset=False
bShowedGenesisDLCMessage=False
bShowedGenesis2DLCMessage=False
bDisableMenuTransitionsPreventEnablingChanged=False
bEnableASACamera=True
bDisableASACameraSmoothing=False

[SessionSettings]
SessionName=${ARK_SESSION_NAME}

[MessageOfTheDay]
Message=Bienvenido al servidor ARK
Duration=20
EOF
    log "GameUserSettings.ini creado/actualizado."
}

# Función para construir argumentos de inicio
build_start_args() {
    local START_ARGS="${ARK_SERVER_MAP}?listen"
    
    # Puerto del servidor
    START_ARGS="${START_ARGS}?Port=${ARK_GAME_PORT}"
    START_ARGS="${START_ARGS}?QueryPort=${ARK_QUERY_PORT}"
    START_ARGS="${START_ARGS}?RCONEnabled=${ARK_RCON_ENABLE}"
    START_ARGS="${START_ARGS}?RCONPort=${ARK_RCON_PORT}"
    
    # Mods si están especificados
    if [ ! -z "${ARK_MODS}" ]; then
        START_ARGS="${START_ARGS}?GameModIds=${ARK_MODS}"
    fi
    
    # Cluster si está especificado
    if [ ! -z "${ARK_CLUSTER_ID}" ]; then
        START_ARGS="${START_ARGS}?ClusterId=${ARK_CLUSTER_ID}"
    fi
    
    # Password
    if [ ! -z "${ARK_SERVER_PASSWORD}" ]; then
        START_ARGS="${START_ARGS}?ServerPassword=${ARK_SERVER_PASSWORD}"
    fi
    
    # Otros argumentos
    START_ARGS="${START_ARGS} -server -log"
    
    # Multihome
    if [ ! -z "${ARK_MULTIHOME}" ]; then
        START_ARGS="${START_ARGS} -multihome=${ARK_MULTIHOME}"
    fi
    
    # BattleEye
    if [ "${ARK_BATTLEYE}" = "True" ]; then
        START_ARGS="${START_ARGS} -UseBattlEye"
    else
        START_ARGS="${START_ARGS} -NoBattlEye"
    fi
    
    # Crossplay
    if [ "${ARK_SERVER_CROSSPLAY}" = "True" ]; then
        START_ARGS="${START_ARGS} -crossplay"
    fi
    
    # Cluster directory override
    if [ ! -z "${ARK_CLUSTER_DIR_OVERRIDE}" ]; then
        START_ARGS="${START_ARGS} -ClusterDirOverride=${ARK_CLUSTER_DIR_OVERRIDE}"
    fi
    
    # Culture
    START_ARGS="${START_ARGS} -culture=${ARK_SERVER_CULTURE}"
    
    echo "${START_ARGS}"
}

# Instalar/Actualizar servidor
install_or_update_ark

# Arreglar permisos después de la instalación de Steam
log "Ajustando permisos de archivos..."
chown -R 1000:1000 /steamcmd/ark 2>/dev/null || true

# Generar configuración
generate_config

# Iniciar aplicaciones Node.js en segundo plano
log "Iniciando aplicaciones de gestión..."

# Heartbeat app
if [ -d "${APP_DIR}/heartbeat_app" ]; then
    cd "${APP_DIR}/heartbeat_app"
    node app.js &
    log "Heartbeat app iniciada."
fi

# Scheduler app
if [ -d "${APP_DIR}/scheduler_app" ]; then
    cd "${APP_DIR}/scheduler_app"
    node app.js &
    log "Scheduler app iniciada."
fi

# RCON app
if [ -d "${APP_DIR}/rcon_app" ]; then
    export RCON_PORT="${ARK_RCON_PORT}"
    export RCON_PASSWORD="${ARK_ADMIN_PASSWORD}"
    log "RCON configurado en puerto ${ARK_RCON_PORT}"
fi

# Construir argumentos de inicio
START_ARGS=$(build_start_args)

log "=========================================="
log "Iniciando servidor ARK..."
log "Mapa: ${ARK_SERVER_MAP}"
log "Puerto: ${ARK_GAME_PORT}"
log "Puerto Query: ${ARK_QUERY_PORT}"
log "Puerto RCON: ${ARK_RCON_PORT}"
log "Max Jugadores: ${ARK_MAX_PLAYERS}"
log "=========================================="

# Cambiar al directorio del servidor
cd "${ARK_DIR}/ShooterGame/Binaries/Linux"

# Cambiar al usuario docker para ejecutar el servidor
log "Cambiando a usuario docker para ejecutar el servidor..."
exec su -s /bin/bash -c "./ShooterGameServer ${START_ARGS}" docker

