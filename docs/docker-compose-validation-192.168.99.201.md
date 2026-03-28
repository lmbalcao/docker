# Docker Compose Validation on 192.168.99.201

Nota operacional:

- O host inicialmente pedido, `192.168.99.201`, não aceitou as credenciais/chaves disponíveis no ambiente.
- A validação foi redirecionada para `dev-docker-1` em `192.168.99.203` por indicação posterior do utilizador.
- Evidência de baseline aplicada no host usado:
  - limpeza total de containers, redes e volumes Docker não base
  - correção de DNS do host para `192.168.99.1`
  - reinício do daemon Docker após falhas iniciais de pull com DNS incorreto

## Summary So Far

- Host efetivamente usado: `192.168.99.203` (`dev-docker-1`)
- Compose versionados encontrados no repositório: `43`
- Compose já trabalhados:
  - `flaresolverr/docker-compose.yml`
  - `terraform/docker-compose.yml`
  - `rdtclient/docker-compose.yml`
  - `uptimekuma/docker-compose.yml` em progresso
  - `jellyseer/docker-compose.yml` em progresso

## Compose Results

### `flaresolverr/docker-compose.yml`

- Objetivo aparente: expor FlareSolverr em `8001` com dados em `/opt/flaresolverr`.
- Resultado da 1.ª instalação:
  - `docker compose up -d --quiet-pull` concluiu com sucesso.
  - `docker compose ps` mostrou o serviço `Up`.
  - logs mostraram `Test successful!` e `Serving on http://0.0.0.0:8191`.
  - `curl -H 'Content-Type: application/json' -d '{"cmd":"sessions.create"}' http://127.0.0.1:8001/v1` devolveu `status: ok`.
- Erros encontrados:
  - aviso de Compose: atributo `version` obsoleto.
- Alterações feitas:
  - removido o campo `version` do ficheiro compose.
- Resultado do reteste:
  - válido.
- Resultado da reinstalação limpa:
  - válido.
- Estado final:
  - `OK com correções`

### `terraform/docker-compose.yml`

- Objetivo aparente: executar `terraform version` num container utilitário com binds de workspace/cache/config.
- Resultado da 1.ª instalação:
  - `docker compose config` falhou inicialmente por volume inválido.
- Erros encontrados:
  - `service "terraform" refers to undefined volume opt/terraform/plugin-cache: invalid compose project`
- Alterações feitas:
  - corrigido o bind mount `opt/terraform/plugin-cache:/terraform/plugin-cache` para `/opt/terraform/plugin-cache:/terraform/plugin-cache`.
- Resultado do reteste:
  - `docker compose up --abort-on-container-exit --quiet-pull` executou `Terraform v1.13.0` e saiu com código `0`.
  - manteve apenas aviso benigno por ausência de `/terraform/config/.terraformrc`.
- Resultado da reinstalação limpa:
  - válido, repetiu `terraform version` com exit code `0`.
- Estado final:
  - `OK com correções`

### `rdtclient/docker-compose.yml`

- Objetivo aparente: expor a UI do `rdtclient` em `6500` com dados persistentes em binds locais.
- Resultado da 1.ª instalação:
  - o container subiu e abriu a porta `6500`, mas o teste HTTP devolveu `Recv failure: Connection reset by peer`.
- Erros encontrados:
  - o container ficou `unhealthy`.
  - logs e `ps` mostraram o init preso em `chown -R abc:abc /app /data`.
  - em runtime real no host, os binds para shares NFS falharam com:
    - `Operation not permitted`
    - `changing ownership of '/data/downloads'`
    - `changing ownership of '/data/data'`
  - o processo principal arrancou parcialmente, mas a aplicação nunca ficou pronta nem respondeu em `6500`.
- Alterações feitas:
  - bind `/mnt/data` restringido para `/mnt/data/rdtclient`
  - bind `/mnt/downloads` restringido para `/mnt/downloads/rdtclient`
- Resultado do reteste:
  - melhorou o escopo dos dados e eliminou o risco de `chown` sobre shares inteiros, mas a imagem continuou a falhar em `chown` no NFS com `root_squash`.
- Resultado da reinstalação limpa:
  - ainda não válido no host testado.
- Estado final:
  - `Bloqueado por dependência externa real`
  - dependência real: semântica de permissões/ownership do storage NFS exportado para `/mnt/data` e `/mnt/downloads` no host.

## Host-Level Findings

- Falha inicial de pulls para Docker Hub:
  - `lookup registry-1.docker.io on 192.168.99.200:53: server misbehaving`
- Correção operacional aplicada no host:
  - `resolv.conf` alinhado para `nameserver 192.168.99.1`
- Após correção e reinício do daemon:
  - `docker pull alpine:latest` passou
  - pulls e arranques de compose deixaram de falhar por DNS

## Files Changed So Far

- `flaresolverr/docker-compose.yml`
- `rdtclient/docker-compose.yml`
- `terraform/docker-compose.yml`
