const express = require('express');
const { default: makeWASocket, useMultiFileAuthState, DisconnectReason, fetchLatestBaileysVersion } = require('@whiskeysockets/baileys');
const qrcode = require('qrcode');
const pino = require('pino');
const path = require('path');
const fs = require('fs');

const app = express();

// Enable CORS for all origins (Admin Dashboard, Flutter Web, local apps)
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }
    next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

let sock = null;
let isConnected = false;
let qrCodeBase64 = '';
let connectedUser = null;

// Live OTP Activity Logs (stores last 15 requests in memory)
const otpLogs = [];

function addLog(to, body, status, errorMsg = '') {
    const timestamp = new Date().toLocaleTimeString('ar-EG', { hour12: false });
    const cleanPhone = (to || '').toString().replace(/\D/g, '');
    
    // Mask middle of phone number for privacy
    let maskedPhone = cleanPhone;
    if (cleanPhone.length > 6) {
        maskedPhone = '+' + cleanPhone.substring(0, 4) + '****' + cleanPhone.substring(cleanPhone.length - 3);
    } else if (cleanPhone.length > 0) {
        maskedPhone = '+' + cleanPhone;
    } else {
        maskedPhone = 'رقم غير معروف';
    }

    // Extract 6-digit OTP code if present
    const otpMatch = (body || '').match(/\b\d{6}\b/);
    const otp = otpMatch ? otpMatch[0] : '---';

    otpLogs.unshift({
        time: timestamp,
        phone: maskedPhone,
        otp: otp,
        status: status,
        error: errorMsg
    });

    if (otpLogs.length > 15) {
        otpLogs.pop();
    }
}

async function connectToWhatsApp() {
    try {
        const authFolder = path.join(__dirname, 'auth_info_baileys');
        if (!fs.existsSync(authFolder)) {
            fs.mkdirSync(authFolder, { recursive: true });
        }

        const { state, saveCreds } = await useMultiFileAuthState(authFolder);
        const { version } = await fetchLatestBaileysVersion().catch(() => ({ version: [2, 3000, 1015901307] }));

        sock = makeWASocket({
            version,
            auth: state,
            printQRInTerminal: true,
            logger: pino({ level: 'silent' }),
            browser: ['Ihtiyajati Gateway', 'Chrome', '1.0.0']
        });

        sock.ev.on('connection.update', async (update) => {
            const { connection, lastDisconnect, qr } = update;

            if (qr) {
                try {
                    qrCodeBase64 = await qrcode.toDataURL(qr);
                } catch (err) {
                    qrCodeBase64 = '';
                }
                isConnected = false;
                connectedUser = null;
                console.log('📷 New WhatsApp QR Code generated. Scan it in Dashboard or at /qr');
            }

            if (connection === 'close') {
                isConnected = false;
                connectedUser = null;
                const statusCode = lastDisconnect?.error?.output?.statusCode;
                const shouldReconnect = statusCode !== DisconnectReason.loggedOut;
                console.log(`❌ WhatsApp connection closed. Reconnecting: ${shouldReconnect} (Status: ${statusCode})`);

                if (shouldReconnect) {
                    setTimeout(connectToWhatsApp, 3000);
                } else {
                    // Session logged out - clean auth folder so user can re-scan QR code cleanly
                    try {
                        fs.rmSync(authFolder, { recursive: true, force: true });
                    } catch (e) {}
                    setTimeout(connectToWhatsApp, 3000);
                }
            } else if (connection === 'open') {
                isConnected = true;
                qrCodeBase64 = ''; // Clear QR code when connected

                const userJid = sock.user?.id || '';
                const rawPhone = userJid.split(':')[0].split('@')[0];
                const formattedPhone = rawPhone ? `+${rawPhone}` : '';
                const userName = sock.user?.name || rawPhone || 'حساب الواتساب المربوط';

                connectedUser = {
                    name: userName,
                    phone: rawPhone,
                    formattedPhone: formattedPhone,
                    profilePic: ''
                };

                // Try fetching profile picture if available
                if (userJid) {
                    try {
                        const ppUrl = await sock.profilePictureUrl(userJid, 'image');
                        if (ppUrl) connectedUser.profilePic = ppUrl;
                    } catch (e) {}
                }

                console.log('==================================================');
                console.log(`✅ WhatsApp Gateway linked successfully! Account: ${userName} (${formattedPhone})`);
                console.log('==================================================');
            }
        });

        sock.ev.on('creds.update', saveCreds);

    } catch (error) {
        console.error('Failed to initialize Baileys WhatsApp client:', error);
        setTimeout(connectToWhatsApp, 5000);
    }
}

connectToWhatsApp();

// Endpoint to view QR Code for linking directly
app.get('/qr', (req, res) => {
    if (isConnected) {
        return res.send(`
            <div style="text-align: center; margin-top: 50px; font-family: Arial, sans-serif;">
                <h2 style="color: #10B981;">✅ WhatsApp is linked and ready!</h2>
                <p>Connected Account: <b>${connectedUser?.name || 'Linked User'}</b> (${connectedUser?.formattedPhone || ''})</p>
                ${connectedUser?.profilePic ? `<img src="${connectedUser.profilePic}" style="width: 100px; height: 100px; border-radius: 50%;" />` : ''}
            </div>
        `);
    }

    if (!qrCodeBase64) {
        return res.send(`
            <div style="text-align: center; margin-top: 50px; font-family: Arial, sans-serif;">
                <h2>⏳ Loading QR Code...</h2>
                <p>Generating session, please refresh this page in 3 seconds.</p>
                <script>setTimeout(() => { location.reload(); }, 3000);</script>
            </div>
        `);
    }

    res.send(`
        <div style="text-align: center; margin-top: 50px; font-family: Arial, sans-serif;">
            <h2 style="color: #0F172A;">🔗 Scan QR Code to Link WhatsApp</h2>
            <p style="color: #475569;">Open WhatsApp on your phone -> Linked Devices -> Link a Device</p>
            <div style="margin: 30px auto; display: inline-block; border: 2px solid #E2E8F0; padding: 20px; border-radius: 12px; background: white;">
                <img src="${qrCodeBase64}" style="width: 250px; height: 250px;" />
            </div>
        </div>
    `);
});

// Endpoint to check active status & connected user details
app.get('/status', (req, res) => {
    res.json({
        ready: isConnected,
        qrCode: qrCodeBase64,
        user: isConnected ? (connectedUser || { name: 'حساب الواتساب المربوط', phone: '', formattedPhone: '', profilePic: '' }) : null,
        logs: otpLogs
    });
});

// Endpoint to logout/unlink session
app.post('/logout', async (req, res) => {
    try {
        if (sock) {
            await sock.logout().catch(() => {});
        }
        isConnected = false;
        connectedUser = null;
        qrCodeBase64 = '';
        const authFolder = path.join(__dirname, 'auth_info_baileys');
        if (fs.existsSync(authFolder)) {
            fs.rmSync(authFolder, { recursive: true, force: true });
        }
        setTimeout(connectToWhatsApp, 1000);
        res.json({ success: true, message: 'Logged out successfully' });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Helper function to format phone numbers to Baileys WhatsApp JID (@s.whatsapp.net)
function formatToWhatsAppJid(to) {
    let clean = (to || '').toString().trim().replace(/\D/g, '');
    if (clean.startsWith('00')) {
        clean = clean.substring(2);
    }
    // Format Iraqi mobile numbers:
    // e.g. 96407513850477 -> 9647513850477
    if (clean.startsWith('96407')) {
        clean = '964' + clean.substring(4);
    }
    // e.g. 07701234567 -> 9647701234567
    else if (clean.startsWith('07') && clean.length === 11) {
        clean = '964' + clean.substring(1);
    }
    // e.g. 7701234567 -> 9647701234567
    else if (clean.startsWith('7') && clean.length === 10) {
        clean = '964' + clean;
    }

    if (!clean.endsWith('@s.whatsapp.net')) {
        clean = `${clean}@s.whatsapp.net`;
    }
    return clean;
}

// Endpoint to send WhatsApp OTP / Text message
app.post('/send-otp', async (req, res) => {
    console.log('📩 Incoming /send-otp request:', req.body);
    const to = req.body?.to || req.query?.to;
    const body = req.body?.body || req.query?.body;

    if (!sock || !isConnected) {
        console.warn('⚠️ send-otp failed: WhatsApp gateway is not connected');
        addLog(to, body, 'failed', 'بوابة الواتساب غير متصلة بالهاتف');
        return res.status(503).json({
            success: false,
            error: 'WhatsApp gateway is not connected. Scan QR code in Dashboard first.'
        });
    }

    if (!to || !body) {
        console.warn('⚠️ send-otp failed: Missing target phone or message body');
        addLog(to, body, 'failed', 'بيانات ناقصة (رقم الهاتف أو نص الرسالة فارغ)');
        return res.status(400).json({
            success: false,
            error: 'Missing target phone ("to") or message body ("body").'
        });
    }

    try {
        const jid = formatToWhatsAppJid(to);
        console.log(`🚀 Sending WhatsApp message via Baileys to: ${jid}`);
        await sock.sendMessage(jid, { text: String(body) });
        console.log(`✅ Message successfully delivered to: ${jid}`);
        addLog(to, body, 'success');
        res.json({ success: true, message: 'Message sent successfully.' });
    } catch (error) {
        console.error('❌ Failed to send WhatsApp message:', error);
        addLog(to, body, 'failed', error.message || 'فشل أثناء الإرسال');
        res.status(500).json({ success: false, error: error.message || 'Failed to send WhatsApp message.' });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Baileys WhatsApp API Gateway listening on port ${PORT}`);
});

