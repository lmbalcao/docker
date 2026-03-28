# Doc/Code Alignment Report

- repo analisado: `docker`
- ficheiros/documentacao inspecionados: `README.md`, `AGENTS.md`, `docs/README.md`, `docs/STATE.md`, inventario de stacks e `docker-compose.yml` ate profundidade 2, `scripts/validate-repo.sh`
- evidencia principal encontrada: existem compose files versionados em stacks como `traefik/`, `forgejo/`, `nextcloud/`, `paperless/`, `immich/`, `monitoring/`, `sftpgo/` e `vscode/`
- inconsistencias encontradas: o README anterior listava `mediasuite` como stack com `docker-compose.yml`, o que nao existe neste repositório
- correcoes aplicadas: `README.md` ajustado para listar apenas exemplos de stacks/versioned compose realmente presentes; criado este relatorio
- validacoes executadas: `bash -n scripts/validate-repo.sh`; `python3 -m py_compile scripts/update-changelog.py`
- limitacoes / pontos nao validados: nao foi executado `docker compose config` em todas as stacks porque varias dependem de `.env`/paths locais nao fornecidos nesta auditoria; o baseline completo tambem fica afetado por delecoes locais pre-existentes em `.claude/` e `.codex/`
- resultado final: docs alinhadas
