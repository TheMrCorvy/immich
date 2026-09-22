# Fix: 413 "File Too Large" on Video Uploads

## Root Cause

Large video uploads fail because of **two bottlenecks** in the request chain:

1. 🔴 **Cloudflare** (Primary) — Imposes a hard 100 MB upload limit when the domain is "Proxied" (orange cloud). This cannot be overridden at the app level.
2. 🟡 **Traefik** (Secondary, on the VPS) — Pangolin's underlying reverse proxy may buffer/limit request body size.

Immich itself (the Docker container) has **no upload size limit**. The error is generated upstream.

---

## Fix 1 — Cloudflare Dashboard (do this first)

1. Log in to [dash.cloudflare.com](https://dash.cloudflare.com)
2. Select your domain → **DNS → Records**
3. Find the `A` record for `z-program.chaldea.foundation`
4. Click the **orange cloud icon** to toggle it to **grey (DNS Only)**
5. Click **Save**

> **Why:** DNS Only routes traffic directly to your VPS IP, bypassing Cloudflare's proxy and its 100 MB limit entirely.

---

## Fix 2 — Traefik on the VPS (run after Fix 1)

SSH into your VPS and run the deployment script:

```bash
ssh your-user@your-vps-ip
bash <(curl -fsSL https://raw.githubusercontent.com/...) 
# OR copy the script from this repo and run it manually (see below)
```

### Manual steps (if you prefer)

1. SSH into your VPS
2. Go to your Pangolin directory (typically `~/pangolin` or wherever you installed it)
3. Edit `config/traefik/dynamic_config.yml` to add the `immich-no-limit` middleware (see `vps-traefik-patch.sh` in this docs folder)
4. Restart Traefik: `docker compose restart traefik`

---

## Verification

After both fixes, test by uploading a video > 200 MB from the Immich web UI or mobile app.

If it still fails, check Traefik logs:
```bash
docker compose logs traefik --tail 100 | grep -i "413\|body\|limit"
```
