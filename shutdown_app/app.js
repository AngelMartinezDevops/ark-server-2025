const Rcon = require('rcon');

// Configuración
const RCON_HOST = process.env.RCON_HOST || 'localhost';
const RCON_PORT = parseInt(process.env.ARK_RCON_PORT || '27020');
const RCON_PASSWORD = process.env.ARK_ADMIN_PASSWORD || 'changeme';

// Tiempos de advertencia antes del apagado (en minutos)
const WARNING_TIMES = [30, 15, 10, 5, 3, 2, 1];

let isShuttingDown = false;

console.log('ARK Shutdown Handler iniciado');
console.log(`RCON: ${RCON_HOST}:${RCON_PORT}`);

// Función para enviar mensaje RCON
function sendRconCommand(command) {
    return new Promise((resolve, reject) => {
        const client = new Rcon(RCON_HOST, RCON_PORT, RCON_PASSWORD);
        
        client.on('auth', () => {
            client.send(command);
        });
        
        client.on('response', (str) => {
            client.disconnect();
            resolve(str);
        });
        
        client.on('error', (err) => {
            reject(err);
        });
        
        client.connect();
    });
}

// Función para broadcast de mensaje
async function broadcast(message) {
    try {
        await sendRconCommand(`ServerChat ${message}`);
        console.log(`Broadcast: ${message}`);
    } catch (err) {
        console.error('Error sending broadcast:', err.message);
    }
}

// Función para guardar el mundo
async function saveWorld() {
    try {
        await sendRconCommand('SaveWorld');
        console.log('Mundo guardado');
    } catch (err) {
        console.error('Error guardando mundo:', err.message);
    }
}

// Función para realizar shutdown gradual
async function gracefulShutdown() {
    if (isShuttingDown) return;
    isShuttingDown = true;
    
    console.log('Iniciando shutdown gradual...');
    
    // Enviar advertencias
    for (const minutes of WARNING_TIMES) {
        await broadcast(`ADVERTENCIA: El servidor se reiniciará en ${minutes} minuto(s)`);
        await new Promise(resolve => setTimeout(resolve, 60000)); // Esperar 1 minuto
    }
    
    // Advertencia final
    await broadcast('¡El servidor se está apagando AHORA!');
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    // Guardar mundo
    await saveWorld();
    await new Promise(resolve => setTimeout(resolve, 10000));
    
    // Apagar servidor
    console.log('Apagando servidor ARK...');
    try {
        await sendRconCommand('DoExit');
    } catch (err) {
        console.error('Error ejecutando DoExit:', err.message);
    }
    
    // Dar tiempo para que el servidor se apague
    setTimeout(() => {
        console.log('Forzando salida del proceso');
        process.exit(0);
    }, 30000);
}

// Capturar señales de terminación
process.on('SIGTERM', () => {
    console.log('Señal SIGTERM recibida');
    gracefulShutdown();
});

process.on('SIGINT', () => {
    console.log('Señal SIGINT recibida');
    gracefulShutdown();
});

// Mantener el proceso vivo
setInterval(() => {
    // Heartbeat silencioso
}, 60000);

console.log('Shutdown handler listo. Esperando señales...');

