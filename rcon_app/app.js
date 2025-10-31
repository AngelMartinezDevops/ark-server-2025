#!/usr/bin/env node

const Rcon = require('rcon');

// Configuración
const RCON_HOST = process.env.RCON_HOST || 'localhost';
const RCON_PORT = parseInt(process.env.ARK_RCON_PORT || '27020');
const RCON_PASSWORD = process.env.ARK_ADMIN_PASSWORD || 'changeme';

// Obtener comando de argumentos
const command = process.argv.slice(2).join(' ');

if (!command) {
    console.error('Uso: rcon <comando>');
    console.error('');
    console.error('Ejemplos:');
    console.error('  rcon ListPlayers');
    console.error('  rcon SaveWorld');
    console.error('  rcon ServerChat "Hola a todos"');
    console.error('  rcon Broadcast "Mensaje importante"');
    console.error('  rcon DoExit');
    console.error('');
    console.error('Comandos ARK comunes:');
    console.error('  ListPlayers         - Lista jugadores conectados');
    console.error('  SaveWorld           - Guarda el mundo');
    console.error('  ServerChat <msg>    - Envía mensaje al chat');
    console.error('  Broadcast <msg>     - Broadcast a todos');
    console.error('  DoExit              - Apaga el servidor');
    console.error('  SetTimeOfDay <time> - Cambia hora (ej: 12:00)');
    console.error('  KickPlayer <name>   - Expulsa jugador');
    console.error('  BanPlayer <name>    - Banea jugador');
    process.exit(1);
}

console.log(`Conectando a ${RCON_HOST}:${RCON_PORT}...`);
console.log(`Comando: ${command}`);
console.log('');

// Crear cliente RCON
const client = new Rcon(RCON_HOST, RCON_PORT, RCON_PASSWORD);

// Timeout de 10 segundos
const timeout = setTimeout(() => {
    console.error('Error: Timeout esperando respuesta del servidor');
    client.disconnect();
    process.exit(1);
}, 10000);

client.on('auth', () => {
    console.log('✓ Autenticado');
    client.send(command);
});

client.on('response', (str) => {
    clearTimeout(timeout);
    console.log('Respuesta del servidor:');
    console.log('------------------------');
    console.log(str || '(sin respuesta)');
    console.log('------------------------');
    client.disconnect();
    process.exit(0);
});

client.on('error', (err) => {
    clearTimeout(timeout);
    console.error('Error:', err.message);
    client.disconnect();
    process.exit(1);
});

client.on('end', () => {
    clearTimeout(timeout);
});

// Conectar
client.connect();

