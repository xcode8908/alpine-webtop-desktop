# Alpine XFCE Webtop Desktop (Cloud PC)

Ultra-lightweight Visual Cloud Desktop running Alpine Linux 3.20 + XFCE on Render's Free Tier with 4-Layer RAM Guardrail (< 490 MB) and 24/7 Zero Cold-Start Keep-Alive.

## Features
- **Visual Desktop UI:** Windows-like intuitive interface with desktop icons, start menu, taskbar, terminal, file manager, and text editor.
- **Ultra-Low Memory Footprint:** Uses ~140-160 MB base RAM, guarded under 490 MB to prevent Render Free Tier 512 MB OOM crashes.
- **KasmVNC HTML5 Web Access:** Seamless browser-based streaming with WebSockets and clipboard support.
- **Internal Nginx Gateway:** Dedicated reverse proxy routing `/health` (unauthenticated for Render / Watchdog uptime) and `/` (password-protected with Basic Auth).
- **24/7 Keep-Alive:** Integrated with Self-Heal Sentry Watchdog to eliminate 40-second cold starts.

## Credentials
- **Username:** `lipan`
- **Password:** `Lipan8908@`
- **Port:** `$PORT` (dynamically bound)
