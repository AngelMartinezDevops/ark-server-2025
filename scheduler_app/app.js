const cron = require('node-cron');
const Rcon = require('rcon');

// Configuración
const RCON_HOST = process.env.RCON_HOST || 'localhost';
const RCON_PORT = parseInt(process.env.ARK_RCON_PORT || '27020');
const RCON_PASSWORD = process.env.ARK_ADMIN_PASSWORD || 'changeme';

// Configuración de reinicio automático
const AUTO_RESTART_ENABLED = process.env.ARK_AUTO_RESTART_ENABLED === 'true';
const AUTO_RESTART_CRON = process.env.ARK_AUTO_RESTART_CRON || '0 4 * * *'; // 4 AM diario

console.log('ARK Scheduler iniciado');
console.log(`RCON: ${RCON_HOST}:${RCON_PORT}`);
console.log(`Auto-restart: ${AUTO_RESTART_ENABLED ? 'Habilitado' : 'Deshabilitado'}`);

if (AUTO_RESTART_ENABLED) {
    console.log(`Cron schedule: ${AUTO_RESTART_CRON}`);
}

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
        console.error('Error en broadcast:', err.message);
    }
}

// Función para guardar mundo
async function saveWorld() {
    try {
        await sendRconCommand('SaveWorld');
        console.log('Mundo guardado por scheduler');
        return true;
    } catch (err) {
        console.error('Error guardando mundo:', err.message);
        return false;
    }
}

// Programar guardado automático cada 15 minutos
cron.schedule('*/15 * * * *', async () => {
    console.log('Ejecutando guardado automático...');
    await saveWorld();
});

// Programar reinicio automático si está habilitado
if (AUTO_RESTART_ENABLED) {
    cron.schedule(AUTO_RESTART_CRON, async () => {
        console.log('Iniciando reinicio programado...');
        
        // Advertencias progresivas
        await broadcast('¡REINICIO AUTOMÁTICO EN 30 MINUTOS!');
        await new Promise(resolve => setTimeout(resolve, 900000)); // 15 min
        
        await broadcast('¡REINICIO AUTOMÁTICO EN 15 MINUTOS!');
        await new Promise(resolve => setTimeout(resolve, 600000)); // 10 min
        
        await broadcast('¡REINICIO AUTOMÁTICO EN 5 MINUTOS!');
        await new Promise(resolve => setTimeout(resolve, 240000)); // 4 min
        
        await broadcast('¡REINICIO AUTOMÁTICO EN 1 MINUTO!');
        await new Promise(resolve => setTimeout(resolve, 30000)); // 30 seg
        
        await broadcast('¡REINICIANDO AHORA!');
        await new Promise(resolve => setTimeout(resolve, 5000));
        
        // Guardar y reiniciar
        await saveWorld();
        await new Promise(resolve => setTimeout(resolve, 10000));
        
        try {
            await sendRconCommand('DoExit');
        } catch (err) {
            console.error('Error en reinicio:', err.message);
        }
    });
}

// Mensaje de bienvenida cada hora
cron.schedule('0 * * * *', async () => {
    await broadcast('¡Servidor ARK activo! Discord: tu-discord-aqui');
});

// Mantener proceso activo
console.log('Scheduler configurado y activo');

