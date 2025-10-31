# Script de construcción para ARK Server Docker Image (Windows PowerShell)
# Uso: .\build.ps1 [tag]

param(
    [string]$Tag = "latest"
)

$ErrorActionPreference = "Stop"

# Configuración
$ImageName = "b3lerofonte/ark-server"

Write-Host "========================================" -ForegroundColor Blue
Write-Host "ARK Server - Build Script" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# Verificar que Docker está instalado
try {
    $dockerVersion = docker --version
    Write-Host "✓ Docker encontrado: $dockerVersion" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Error: Docker no está instalado" -ForegroundColor Red
    exit 1
}

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "Dockerfile")) {
    Write-Host "Error: Dockerfile no encontrado" -ForegroundColor Red
    Write-Host "Ejecuta este script desde el directorio del proyecto" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Dockerfile encontrado" -ForegroundColor Green
Write-Host ""

# Obtener información de Git (si está disponible)
$gitRef = "unknown"
try {
    $gitRef = git rev-parse --short HEAD 2>$null
} catch {
    # Git no disponible o no es un repositorio
}

# Construir imagen
Write-Host "Construyendo imagen: ${ImageName}:${Tag}" -ForegroundColor Blue
Write-Host ""

$buildDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

docker build `
    -t "${ImageName}:${Tag}" `
    --build-arg BUILD_DATE="$buildDate" `
    --build-arg VCS_REF="$gitRef" `
    .

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ Build completado exitosamente" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Imagen construida: ${ImageName}:${Tag}"
    Write-Host ""
    Write-Host "Comandos útiles:"
    Write-Host "  docker images $ImageName"
    Write-Host "  docker run -d ${ImageName}:${Tag}"
    Write-Host "  docker compose up -d"
    Write-Host "  docker push ${ImageName}:${Tag}"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "✗ Build falló" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit 1
}

