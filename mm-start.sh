#!/bin/sh
set -e

PAPERCLIP_HOME="${PAPERCLIP_HOME:-/paperclip}"
INSTANCE="${PAPERCLIP_INSTANCE_ID:-default}"
CFG_DIR="$PAPERCLIP_HOME/instances/$INSTANCE"
CFG_FILE="$CFG_DIR/config.json"

mkdir -p "$CFG_DIR/db"
mkdir -p "$CFG_DIR/data/storage"

# Write config - use external postgres if DATABASE_URL is set, else embedded
if [ -n "$DATABASE_URL" ]; then
  DB_JSON="{\"mode\":\"postgres\",\"connectionString\":\"$DATABASE_URL\"}"
else
  DB_JSON="{\"mode\":\"embedded-postgres\",\"embeddedPostgresDataDir\":\"$CFG_DIR/db\"}"
fi

node -e "
var fs=require('fs');
var db=$DB_JSON;
var cfg={
  database:db,
  server:{host:'0.0.0.0',port:3100,serveUi:true,deploymentMode:'${PAPERCLIP_DEPLOYMENT_MODE:-authenticated}',exposure:'${PAPERCLIP_DEPLOYMENT_EXPOSURE:-private}'},
  auth:{baseUrlMode:'env',disableSignUp:false},
  logging:{mode:'stdout'},
  storage:{provider:'local_disk',localDisk:{baseDir:'$CFG_DIR/data/storage'}}
};
fs.writeFileSync('$CFG_FILE',JSON.stringify(cfg,null,2));
console.log('Config written:', '$CFG_FILE');
console.log('Database mode:', cfg.database.mode);
"

echo "Starting paperclipai..."
exec paperclipai run
