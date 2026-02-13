#!/bin/sh
set -eu

if [ ! -f /scripts/vault-entrypoint.sh ]; then
  echo "ERRO: /scripts/vault-entrypoint.sh não existe."; ls -l /scripts || true; exit 1
fi

# Se quiseres validar executável: [ -x /scripts/vault-entrypoint.sh ] || chmod +x ...

# Entrega a execução ao teu script
exec sh /scripts/vault-entrypoint.sh
