#!/bin/bash
# Script de construcción para ARK Server Docker Image
# Uso: ./build.sh [tag]

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuración
IMAGE_NAME="b3lerofonte/ark-server"
DEFAULT_TAG="latest"
TAG="${1:-$DEFAULT_TAG}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}ARK Server - Build Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker encontrado${NC}"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}Error: Dockerfile no encontrado${NC}"
    echo "Ejecuta este script desde el directorio del proyecto"
    exit 1
fi

echo -e "${GREEN}✓ Dockerfile encontrado${NC}"
echo ""

# Construir imagen
echo -e "${BLUE}Construyendo imagen: ${IMAGE_NAME}:${TAG}${NC}"
echo ""

docker build \
    -t "${IMAGE_NAME}:${TAG}" \
    --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --build-arg VCS_REF="$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')" \
    .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Build completado exitosamente${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Imagen construida: ${IMAGE_NAME}:${TAG}"
    echo ""
    echo "Comandos útiles:"
    echo "  docker images ${IMAGE_NAME}"
    echo "  docker run -d ${IMAGE_NAME}:${TAG}"
    echo "  docker compose up -d"
    echo "  docker push ${IMAGE_NAME}:${TAG}"
    echo ""
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}✗ Build falló${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi

