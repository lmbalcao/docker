em cada docker com db, permitir acesso externo apenas do ip do cloudbeaver:

  db:
    image: docker.io/library/postgres:17
    restart: unless-stopped
  ports: 
    - 5432:5432 (ou a porta default do tipo de db)
(...)