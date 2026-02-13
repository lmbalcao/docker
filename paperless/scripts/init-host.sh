#!/bin/sh
set -eu

# --- DEFINIÇÃO DAS PASTAS NO HOST ---
HOST_DIRS="
/opt/redisdata
/opt/pgdata
/opt/paperless
/mnt/nas1-paperless/media
/mnt/nas1-paperless/export
/mnt/nas1-paperless/consume
/opt/scripts
"

echo "[init-host] a criar pastas no HOST (idempotente)..."
for d in $HOST_DIRS; do
  mkdir -p "$d"
done

echo "[init-host] permissões e donos..."
# Postgres: 999:1000; dirs 700; files 600
chown -R 999:1000 /opt/pgdata
find /opt/pgdata -type d -exec chmod 700 {} \; || true
find /opt/pgdata -type f -exec chmod 600 {} \; || true

# Redis: 999:1000; dirs 755; files 644
chown -R 999:1000 /opt/redisdata
find /opt/redisdata -type d -exec chmod 755 {} \; || true
find /opt/redisdata -type f -exec chmod 644 {} \; || true

# Paperless data dir existe mas dono fica root:root por omissão (ajusta se precisares)
chmod 755 /opt/paperless || true

# NFS (media/export/consume): 1000:1000 recursivo
chown -R 1000:1000 \
  /mnt/nas1-paperless/media \
  /mnt/nas1-paperless/export \
  /mnt/nas1-paperless/consume

# Scripts: 1000:1000
chown -R 1000:1000 /opt/scripts

echo "[init-host] auditoria (numérica):"
/bin/ls -ldn \
  /opt/pgdata \
  /opt/redisdata \
  /opt/paperless \
  /opt/scripts \
  /mnt/nas1-paperless/media \
  /mnt/nas1-paperless/export \
  /mnt/nas1-paperless/consume || true

echo "[init-host] concluído."
