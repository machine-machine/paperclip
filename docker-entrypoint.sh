#!/bin/sh
set -e

CONFIG_DIR="${PAPERCLIP_HOME:-/paperclip}/instances/${PAPERCLIP_INSTANCE_ID:-default}"
CONFIG_FILE="${CONFIG_DIR}/config.json"

# Create config directory
mkdir -p "$CONFIG_DIR"

# Always write config from env vars (allows Coolify env vars to take effect on restart)
if [ -n "$DATABASE_URL" ]; then
  echo "Writing paperclip config from env vars..."
  cat > "$CONFIG_FILE" << EOF
{
  "\$meta": { "version": 1, "updatedAt": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)", "source": "configure" },
  "database": {
    "mode": "postgres",
    "connectionString": "$DATABASE_URL"
  },
  "logging": { "mode": "file" },
  "server": {
    "deploymentMode": "${PAPERCLIP_DEPLOYMENT_MODE:-authenticated}",
    "exposure": "${PAPERCLIP_DEPLOYMENT_EXPOSURE:-private}",
    "host": "${HOST:-0.0.0.0}",
    "port": ${PORT:-3100},
    "allowedHostnames": [],
    "serveUi": true
  },
  "auth": {
    "baseUrlMode": "auto",
    "disableSignUp": false
  },
  "storage": {
    "provider": "local_disk",
    "localDisk": {
      "baseDir": "${PAPERCLIP_HOME:-/paperclip}/instances/${PAPERCLIP_INSTANCE_ID:-default}/data/storage"
    }
  }
}
EOF
  echo "Config written to $CONFIG_FILE"
fi

exec "$@"
