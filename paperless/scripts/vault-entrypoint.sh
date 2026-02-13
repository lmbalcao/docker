#!/usr/bin/env sh
set -eu

: "${VAULT_ADDR:?VAULT_ADDR em falta}"
: "${VAULT_ROLE_ID:?VAULT_ROLE_ID em falta}"
: "${VAULT_SECRET_ID:?VAULT_SECRET_ID em falta}"
: "${VAULT_KV_DATA_PATH:?VAULT_KV_DATA_PATH em falta}"  # ex: secret/data/apps/coolify/prod/paperless

# Permitir tornar a verificação TLS opcional (quando trocares para LE/Cloudflare, define VAULT_INSECURE=false)
VAULT_INSECURE="${VAULT_INSECURE:-true}"

# Dependências mínimas
if ! command -v curl >/dev/null 2>&1; then
  if command -v apk >/dev/null 2>&1; then apk add --no-cache curl >/dev/null
  elif command -v apt-get >/dev/null 2>&1; then apt-get update -qq && apt-get install -y -qq curl >/dev/null && rm -rf /var/lib/apt/lists/*
  else
    echo "Falta 'curl' e não consegui instalar." >&2; exit 1
  fi
fi
if ! command -v jq >/dev/null 2>&1; then
  if command -v apk >/dev/null 2>&1; then apk add --no-cache jq >/dev/null
  elif command -v apt-get >/dev/null 2>&1; then apt-get update -qq && apt-get install -y -qq jq >/dev/null && rm -rf /var/lib/apt/lists/*
  else
    echo "Falta 'jq' e não consegui instalar." >&2; exit 1
  fi
fi

# Self-signed temporário
CURL="curl -sS"
[ "${VAULT_INSECURE}" = "true" ] && CURL="$CURL -k"

# 1) Login AppRole
LOGIN_JSON=$($CURL -X POST "$VAULT_ADDR/v1/auth/approle/login" \
  -H "Content-Type: application/json" \
  -d "{\"role_id\":\"$VAULT_ROLE_ID\",\"secret_id\":\"$VAULT_SECRET_ID\"}" || true)

CLIENT_TOKEN=$(echo "${LOGIN_JSON:-}" | jq -r '.auth.client_token // empty')
if [ -z "$CLIENT_TOKEN" ] || [ "$CLIENT_TOKEN" = "null" ]; then
  echo "Falha no login AppRole ao Vault"; echo "$LOGIN_JSON"; exit 1
fi

# 2) Ler KV v2 (nota: caminho inclui /data/)
DATA_JSON=$($CURL -H "X-Vault-Token: $CLIENT_TOKEN" "$VAULT_ADDR/v1/$VAULT_KV_DATA_PATH" || true)
VALUES=$(echo "${DATA_JSON:-}" | jq '.data.data // empty')

if [ -z "$VALUES" ] || [ "$VALUES" = "null" ]; then
  echo "Sem dados em $VAULT_KV_DATA_PATH. Resposta do Vault:"
  echo "$DATA_JSON"
  exit 1
fi

# 3) Exportar variáveis (para o processo atual)
echo "$VALUES" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' > .env.vault
set -a; . ./.env.vault; set +a
echo "Vault OK → exportadas: $(echo "$VALUES" | jq -r 'keys | join(", ")')"

# 3.5) (Opcional) Construir PAPERLESS_SOCIALACCOUNT_PROVIDERS a partir do Vault
# Requer que no Vault existam: AUTHENTIK_CLIENT_ID, AUTHENTIK_CLIENT_SECRET, AUTHENTIK_APPLICATION_SLUG
if [ -n "${AUTHENTIK_CLIENT_ID:-}" ] && [ -n "${AUTHENTIK_CLIENT_SECRET:-}" ] && [ -n "${AUTHENTIK_APPLICATION_SLUG:-}" ]; then
  AUTHENTIK_SERVER_URL="https://authentik.company/application/o/${AUTHENTIK_APPLICATION_SLUG}/.well-known/openid-configuration"
  export PAPERLESS_SOCIALACCOUNT_PROVIDERS="$(cat <<JSON
{
  "openid_connect": {
    "APPS": [
      {
        "provider_id": "authentik",
        "name": "authentik",
        "client_id": "${AUTHENTIK_CLIENT_ID}",
        "secret": "${AUTHENTIK_CLIENT_SECRET}",
        "settings": {
          "server_url": "${AUTHENTIK_SERVER_URL}",
          "claims": {"username": "email"}
        }
      }
    ],
    "OAUTH_PKCE_ENABLED": "True"
  }
}
JSON
)"
  echo "Configurado PAPERLESS_SOCIALACCOUNT_PROVIDERS a partir do Vault."
fi

# 4) Arrancar o processo original da imagem
exec "$@"
