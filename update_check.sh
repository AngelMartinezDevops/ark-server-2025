#!/bin/bash
# Script para verificar actualizaciones de ARK

ARK_APP_ID="376030"
STEAMCMD_DIR="/steamcmd"
ARK_DIR="/steamcmd/ark"

echo "Verificando actualizaciones para ARK (AppID: ${ARK_APP_ID})..."

# Obtener buildid instalado
INSTALLED_BUILDID=""
if [ -f "${ARK_DIR}/steamapps/appmanifest_${ARK_APP_ID}.acf" ]; then
    INSTALLED_BUILDID=$(grep -oP '(?<="buildid"\s+")[^"]+' "${ARK_DIR}/steamapps/appmanifest_${ARK_APP_ID}.acf" | head -1)
fi

if [ -z "${INSTALLED_BUILDID}" ]; then
    echo "No se pudo determinar la versión instalada."
    echo "Puede que el servidor no esté instalado aún."
    exit 1
fi

echo "BuildID instalado: ${INSTALLED_BUILDID}"

# Verificar última versión disponible
cd "${STEAMCMD_DIR}"
./steamcmd.sh +login anonymous +app_info_update 1 +app_info_print ${ARK_APP_ID} +quit > /tmp/ark_app_info.txt

# Extraer buildid más reciente
LATEST_BUILDID=$(grep -oP '(?<="buildid"\s+")[^"]+' /tmp/ark_app_info.txt | head -1)

if [ -z "${LATEST_BUILDID}" ]; then
    echo "No se pudo determinar la última versión disponible."
    exit 1
fi

echo "BuildID disponible: ${LATEST_BUILDID}"

# Comparar versiones
if [ "${INSTALLED_BUILDID}" != "${LATEST_BUILDID}" ]; then
    echo "¡Actualización disponible!"
    echo "Instalado: ${INSTALLED_BUILDID}"
    echo "Disponible: ${LATEST_BUILDID}"
    exit 0
else
    echo "El servidor está actualizado."
    exit 1
fi

