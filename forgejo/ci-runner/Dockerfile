FROM node:22-bookworm

# ferramentas sistema
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      python3-pip \
      shellcheck \
      curl \
      git \
      tar \
      unzip \
    && rm -rf /var/lib/apt/lists/*

# ferramentas Python CI
RUN pip install --quiet --break-system-packages \
      pip-audit \
      bandit \
      ruff \
      checkov \
      ansible \
      ansible-lint

# collections Ansible pré-instaladas
RUN ansible-galaxy collection install \
      "ansible.posix>=1.5.0" \
      "ansible.windows>=2.0.0"

# gitleaks pré-instalado
RUN curl -fsSL --connect-timeout 30 --max-time 120 \
      -o /tmp/gitleaks.tar.gz \
      https://github.com/gitleaks/gitleaks/releases/download/v8.21.2/gitleaks_8.21.2_linux_x64.tar.gz \
    && tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin gitleaks \
    && rm /tmp/gitleaks.tar.gz \
    && gitleaks version
