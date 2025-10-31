const Rcon = require('rcon');

// Configuración
const RCON_HOST = process.env.RCON_HOST || 'localhost';
const RCON_PORT = parseInt(process.env.ARK_RCON_PORT || '27020');
const RCON_PASSWORD = process.env.ARK_ADMIN_PASSWORD || 'changeme';

console.log('ARK Restart Handler iniciado');

// Función para enviar comando RCON
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

// Función para broadcast
async function broadcast(message) {
    try {
        await sendRconCommand(`ServerChat ${message}`);
        console.log(`Broadcast: ${message}`);
    } catch (err) {
        console.error('Error:', err.message);
    }
}

// Función para guardar mundo
async function saveWorld() {
    try {
        await sendRconCommand('SaveWorld');
        console.log('Mundo guardado');
    } catch (err) {
        console.error('Error guardando:', err.message);
    }
}

// Función principal de restart
async function restartServer() {
    console.log('Iniciando proceso de reinicio...');
    
    // Advertencias
    await broadcast('ADVERTENCIA: Reinicio del servidor en 5 minutos');
    await new Promise(resolve => setTimeout(resolve, 180000)); // 3 min
    
    await broadcast('ADVERTENCIA: Reinicio del servidor en 2 minutos');
    await new Promise(resolve => setTimeout(resolve, 60000)); // 1 min
    
    await broadcast('ADVERTENCIA: Reinicio del servidor en 1 minuto');
    await new Promise(resolve => setTimeout(resolve, 30000)); // 30 seg
    
    await broadcast('¡Reiniciando servidor en 30 segundos!');
    await new Promise(resolve => setTimeout(resolve, 20000)); // 20 seg
    
    await broadcast('¡Reiniciando AHORA!');
    await new Promise(resolve => setTimeout(resolve, 5000)); // 5 seg
    
    // Guardar
    await saveWorld();
    await new Promise(resolve => setTimeout(resolve, 10000));
    
    // Reiniciar
    console.log('Ejecutando restart...');
    try {
        await sendRconCommand('DoExit');
    } catch (err) {
        console.error('Error:', err.message);
    }
    
    setTimeout(() => {
        process.exit(0);
    }, 30000);
}

// Si se ejecuta directamente
if (require.main === module) {
    restartServer();
}

module.exports = { restartServer };

