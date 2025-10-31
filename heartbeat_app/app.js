const Rcon = require('rcon');

// Configuración
const RCON_HOST = process.env.RCON_HOST || 'localhost';
const RCON_PORT = parseInt(process.env.ARK_RCON_PORT || '27020');
const RCON_PASSWORD = process.env.ARK_ADMIN_PASSWORD || 'changeme';
const CHECK_INTERVAL = parseInt(process.env.HEARTBEAT_INTERVAL || '60000'); // 1 minuto

let consecutiveFailures = 0;
const MAX_FAILURES = 5;

console.log('ARK Heartbeat Monitor iniciado');
console.log(`RCON: ${RCON_HOST}:${RCON_PORT}`);
console.log(`Intervalo de chequeo: ${CHECK_INTERVAL}ms`);

// Función para verificar servidor
function checkServer() {
    return new Promise((resolve, reject) => {
        const client = new Rcon(RCON_HOST, RCON_PORT, RCON_PASSWORD);
        const timeout = setTimeout(() => {
            client.disconnect();
            reject(new Error('Timeout'));
        }, 10000);
        
        client.on('auth', () => {
            clearTimeout(timeout);
            client.send('ListPlayers');
        });
        
        client.on('response', (str) => {
            clearTimeout(timeout);
            client.disconnect();
            resolve(str);
        });
        
        client.on('error', (err) => {
            clearTimeout(timeout);
            reject(err);
        });
        
        client.connect();
    });
}

// Función de heartbeat
async function heartbeat() {
    try {
        const response = await checkServer();
        
        if (consecutiveFailures > 0) {
            console.log('✓ Servidor recuperado');
            consecutiveFailures = 0;
        }
        
        // Log silencioso en operación normal
        if (process.env.HEARTBEAT_VERBOSE === 'true') {
            console.log(`✓ Heartbeat OK - ${new Date().toISOString()}`);
        }
        
    } catch (err) {
        consecutiveFailures++;
        console.error(`✗ Heartbeat falló (${consecutiveFailures}/${MAX_FAILURES}): ${err.message}`);
        
        if (consecutiveFailures >= MAX_FAILURES) {
            console.error('¡CRÍTICO! Servidor no responde después de múltiples intentos');
            // Aquí podrías implementar notificaciones (Discord webhook, etc.)
        }
    }
}

// Ejecutar heartbeat inicial después de 30 segundos (dar tiempo al servidor para iniciar)
setTimeout(() => {
    console.log('Iniciando monitoreo...');
    heartbeat(); // Primera verificación
    
    // Programar verificaciones periódicas
    setInterval(heartbeat, CHECK_INTERVAL);
}, 30000);

// Mantener proceso vivo
console.log('Heartbeat monitor configurado. Esperando 30s antes de iniciar checks...');

