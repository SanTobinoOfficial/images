/**
 * Snake Live – Event Bridge Server
 *
 * Uruchomienie:
 *   npm install
 *   node server.js
 *
 * Opcjonalnie z TikTok Live (wymaga: npm install tiktok-live-connector):
 *   TIKTOK_USERNAME=@twojnazwa node server.js
 */

const { WebSocketServer } = require('ws');

const PORT = process.env.PORT || 8080;
const TIKTOK_USER = process.env.TIKTOK_USERNAME || null;

const wss = new WebSocketServer({ port: PORT });
const clients = new Set();

wss.on('connection', (ws, req) => {
  const ip = req.socket.remoteAddress;
  clients.add(ws);
  console.log(`[+] Klient połączony: ${ip}  (łącznie: ${clients.size})`);

  ws.on('message', raw => {
    // Wiadomość od panelu → roześlij do wszystkich (stream pages)
    try {
      const data = JSON.parse(raw);
      broadcast(data, ws);
      console.log(`[EVENT] ${data.type}`, data.username || '');
    } catch (e) {
      console.error('[ERR] Nieprawidłowy JSON:', e.message);
    }
  });

  ws.on('close', () => {
    clients.delete(ws);
    console.log(`[-] Klient rozłączony  (pozostało: ${clients.size})`);
  });

  ws.on('error', err => console.error('[WS ERR]', err.message));
});

function broadcast(data, sender = null) {
  const msg = JSON.stringify(data);
  for (const c of clients) {
    if (c !== sender && c.readyState === 1 /* OPEN */) {
      c.send(msg);
    }
  }
}

console.log(`\n🎮 Snake Live Event Server`);
console.log(`   WebSocket: ws://localhost:${PORT}`);
console.log(`   Panel:     http://localhost:${PORT}/panel.html\n`);

// ─── OPCJONALNE: TikTok Live Connector ───────────────────────────────────────
if (TIKTOK_USER) {
  let TikTokLiveConnector;
  try {
    TikTokLiveConnector = require('tiktok-live-connector');
  } catch {
    console.warn('[WARN] tiktok-live-connector nie jest zainstalowany.');
    console.warn('       Uruchom: npm install tiktok-live-connector\n');
    process.exit(0);
  }

  const { WebcastPushConnection } = TikTokLiveConnector;
  const tiktok = new WebcastPushConnection(TIKTOK_USER);

  const GIFT_MAP = {
    // id prezentów TikTok → emoji + tier
    // Wpisz tu swoje prezenty z TikTok Studio
    1:   { emoji: '🌹', tier: 1   },
    5655:{ emoji: '🌻', tier: 1   },
    5496:{ emoji: '🐼', tier: 5   },
    7770:{ emoji: '👑', tier: 5   },
    208: { emoji: '🦁', tier: 50  },
    246: { emoji: '🌌', tier: 500 },
  };

  tiktok.connect().then(() => {
    console.log(`[TikTok] Połączono z live ${TIKTOK_USER}`);
  }).catch(e => {
    console.error('[TikTok] Błąd połączenia:', e.message);
  });

  tiktok.on('follow', data => {
    broadcast({ type:'follow', username: data.uniqueId });
  });

  tiktok.on('like', data => {
    broadcast({ type:'like', count: data.likeCount, username: data.uniqueId });
  });

  tiktok.on('gift', data => {
    if (data.giftType === 1 && !data.repeatEnd) return; // ignore repeating gifts until streak ends
    const info = GIFT_MAP[data.giftId] || { emoji: '🎁', tier: 1 };
    broadcast({
      type:     'gift',
      giftId:   data.giftId,
      emoji:    info.emoji,
      username: data.uniqueId,
      tier:     info.tier,
      count:    data.repeatCount || 1,
    });
  });

  tiktok.on('chat', data => {
    broadcast({ type:'comment', username: data.uniqueId, text: data.comment });
  });

  tiktok.on('disconnected', () => {
    console.log('[TikTok] Rozłączono, próba ponownego połączenia za 5s...');
    setTimeout(() => tiktok.connect().catch(() => {}), 5000);
  });
}
