#!/bin/sh
set -eu

# Criar diretórios
mkdir -p \
  /opt/redisdata \
  /opt/pgdata \
  /opt/paperless \
  /mnt/nas1-paperless/media \
  /mnt/nas1-paperless/export \
  /mnt/nas1-paperless/consume \
  /opt/scripts
