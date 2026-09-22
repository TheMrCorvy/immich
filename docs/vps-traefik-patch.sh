#!/usr/bin/env bash
# =============================================================================
# vps-traefik-patch.sh
# Patches the Pangolin/Traefik config on your VPS to remove the upload size
# limit for the Immich resource.
#
# USAGE (on your VPS, inside the Pangolin install directory):
#   bash vps-traefik-patch.sh [path-to-pangolin-dir]
#
# If no path is provided, it defaults to the current directory.
# =============================================================================

set -euo pipefail

PANGOLIN_DIR="${1:-$(pwd)}"
DYNAMIC_CONFIG="${PANGOLIN_DIR}/config/traefik/dynamic_config.yml"

# ── Sanity checks ─────────────────────────────────────────────────────────────
if [[ ! -f "$DYNAMIC_CONFIG" ]]; then
  echo "❌  Could not find: $DYNAMIC_CONFIG"
  echo "    Please pass your Pangolin directory as an argument:"
  echo "    bash vps-traefik-patch.sh /path/to/pangolin"
  exit 1
fi

if grep -q "immich-no-limit" "$DYNAMIC_CONFIG"; then
  echo "✅  The 'immich-no-limit' middleware is already present in $DYNAMIC_CONFIG"
  echo "    No changes needed. Exiting."
  exit 0
fi

# ── Backup ────────────────────────────────────────────────────────────────────
BACKUP="${DYNAMIC_CONFIG}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$DYNAMIC_CONFIG" "$BACKUP"
echo "📦  Backed up existing config to: $BACKUP"

# ── Inject middleware into the http.middlewares block ─────────────────────────
# We use Python (available on virtually all Linux VPS images) for safe YAML
# manipulation rather than fragile sed/awk on structured config files.
python3 - "$DYNAMIC_CONFIG" <<'PYEOF'
import sys
import re

config_path = sys.argv[1]

with open(config_path, "r") as f:
    content = f.read()

# The middleware block to inject
middleware_block = """
    # ── Immich: remove upload body size limit ──────────────────────────────
    immich-no-limit:
      buffering:
        maxRequestBodyBytes: 0       # 0 = unlimited
        memRequestBodyBytes: 10485760  # 10 MB in-memory; larger bodies go to disk
"""

# Find the `http:` section and then `middlewares:` inside it
# We insert our block right after the `middlewares:` key
pattern = r"(^http:\s*\n(?:.*\n)*?^\s{2}middlewares:\s*\n)"

match = re.search(pattern, content, flags=re.MULTILINE)
if match:
    insert_at = match.end()
    content = content[:insert_at] + middleware_block + content[insert_at:]
    with open(config_path, "w") as f:
        f.write(content)
    print("✅  Middleware 'immich-no-limit' injected successfully.")
else:
    # No existing middlewares block: prepend a full http.middlewares section
    print("⚠️   No existing 'http.middlewares' block found.")
    print("    Adding a new one at the top of the file...")
    prepend = """http:
  middlewares:
""" + middleware_block + "\n"
    # If http: already exists at root, insert after it; otherwise just prepend
    if re.search(r"^http:", content, re.MULTILINE):
        content = re.sub(
            r"^(http:\s*\n)",
            r"\1  middlewares:\n" + middleware_block + "\n",
            content,
            count=1,
            flags=re.MULTILINE,
        )
    else:
        content = prepend + content
    with open(config_path, "w") as f:
        f.write(content)
    print("✅  Done.")
PYEOF

# ── Restart Traefik ───────────────────────────────────────────────────────────
echo ""
echo "🔄  Restarting Traefik to apply the new middleware..."
cd "$PANGOLIN_DIR"
docker compose restart traefik

echo ""
echo "✅  Done! Traefik restarted."
echo ""
echo "👉  Next steps:"
echo "    1. Make sure you've set Cloudflare DNS to 'DNS Only' (grey cloud)"
echo "       for your Immich domain in the Cloudflare dashboard."
echo "    2. Test by uploading a large video (> 200 MB) via the Immich web UI."
echo "    3. If it still fails, check logs:"
echo "       docker compose logs traefik --tail 100"
