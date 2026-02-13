# 📜 Certificados Let's Encrypt com Certbot + Cloudflare (Coolify)

Este projeto utiliza **Docker Compose** para emitir certificados TLS (Let's Encrypt) de forma automatizada, usando o plugin **DNS-Cloudflare**.  
A integração foi desenhada para correr dentro do **Coolify**, mas pode ser usada noutros ambientes Docker.

---

## 📦 Serviços incluídos

### 🔑 `init-cf-ini`
- Baseado em `alpine:3.21`.
- Cria o ficheiro `cf.ini` com o token da Cloudflare.
- Aplica permissões seguras (`chmod 600`).
- Monta o volume persistente `/data/coolify/proxy/cert_manual1:/etc/letsencrypt`.

### 🪪 `certbot-once`
- Baseado em `certbot/dns-cloudflare:v4.1.1`.
- Corre **apenas uma vez** para emitir o certificado (`certonly`).
- Solicita certificados para:
  - `lbtec.org`
  - `*.lbtec.org` (wildcard).
- Usa a Cloudflare como provedor DNS para validação ACME.

---

## ⚙️ Variáveis de ambiente

Estas variáveis devem ser definidas no **Coolify** (ou no `.env` se usado fora dele):

| Variável                | Obrigatória | Descrição                                                                 | Exemplo                                                                 |
|--------------------------|-------------|---------------------------------------------------------------------------|-------------------------------------------------------------------------|
| `CLOUDFLARE_API_TOKEN`   | ✅          | Token da Cloudflare com permissão **"Edit DNS"**                          | `cf_api_token_xxxxxxxxx`                                                |
| `CERTBOT_EMAIL`          | ✅          | Email de contacto para a ACME                                             | `admin@lbtec.org`                                                       |
| `CERTBOT_SERVER`         | ❌          | Endpoint ACME (staging ou produção)                                       | `https://acme-v02.api.letsencrypt.org/directory`                        |
| `DNS_PROPAGATION_SECONDS`| ❌          | Tempo de espera para propagação DNS                                       | `60`                                                                    |

---

## 🚀 Como usar

1. Defina as variáveis no **Coolify** (ou `.env`).
2. Faça o deploy do `docker-compose.yml`.
3. Verifique os certificados em:

/data/coolify/proxy/cert_manual1/live/lbtec.org/

Os ficheiros principais serão:
- `fullchain.pem` (cadeia pública)
- `privkey.pem` (chave privada)

---

## 🔍 Notas importantes

- O `CERTBOT_SERVER` está configurado para **Staging** por omissão (evita limites de rate).  
Para produção, defina:
```env
CERTBOT_SERVER=https://acme-v02.api.letsencrypt.org/directory

Este setup apenas emite o certificado uma vez.
Para renovações automáticas, deverá criar um cron job ou serviço repetitivo.

O volume /data/coolify/proxy/cert_manual1 contém:

live/       # certificados ativos
archive/    # histórico
logs/       # logs de emissão
work/       # ficheiros temporários



---

🛠️ Troubleshooting

Erro de propagação DNS
→ Aumente DNS_PROPAGATION_SECONDS (ex: 120).

Certificado não aparece
→ Verifique os logs:

docker logs <nome_do_container_certbot>

Problemas com permissões
→ Confirme que o volume /data/coolify/proxy/cert_manual1 tem dono root:root e permissões corretas.



---

✍️ Autor: Luís Balcão
🔗 Projeto LBTEC — Automação de certificados
