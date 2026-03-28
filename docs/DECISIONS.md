# Decisions

- 2026-03-28: `docs/` passa a ser a fonte de verdade documental.
- 2026-03-28: `AGENTS.md` e `.claude/CLAUDE.md` passam a apontar primeiro para `docs/`.
- 2026-03-28: caches, artifacts e restantes ficheiros operacionais transitórios deixam de ser versionáveis.
- 2026-03-28: a validação Compose em curso usa `192.168.99.203` (`dev-docker-1`) por redirecionamento explícito do utilizador após bloqueio de autenticação em `192.168.99.201`.
