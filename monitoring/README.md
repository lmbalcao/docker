Stack de Monitorização Centralizada

Este repositório documenta a stack de monitorização centralizada responsável pela recolha de métricas, ingestão de logs, visualização e gestão de alertas de toda a infraestrutura.

A stack foi desenhada para ambientes self-hosted, segmentados por VLAN e preparada para escala e alta disponibilidade.

1. Estrutura Base

Toda a configuração reside em:

/opt/monitoring


Este diretório contém:

Configuração do Prometheus

Targets dinâmicos (file_sd)

Regras de alertas

Configuração do Loki

Configuração do Promtail

Dashboards e provisioning do Grafana

Configuração do Alertmanager

Integração de notificações via ntfy

2. Fontes de Métricas e Logs

A stack recolhe métricas, estados e logs a partir das seguintes fontes.

2.1 Node Exporter

Serviço: prometheus-node-exporter

Tipo: métricas de sistema

Porta: 9100/TCP

Métricas: CPU, RAM, disco, rede, filesystem

Origem: hosts Linux, VMs, LXC, OpenWrt (via exporter específico)

Linux (Debian / Ubuntu)

Todos os hosts Linux devem ter:

apt update
apt install -y prometheus-node-exporter
systemctl enable --now prometheus-node-exporter

OpenWrt

Node exporter instalado via pacote específico (dependente da versão / arquitetura).

2.2 Proxmox Exporter

Serviço: pve-exporter

Tipo: métricas do Proxmox VE

Porta: 9221/TCP

Dados: nodes, VMs, LXCs, storage, cluster

Fluxo: Prometheus → pve-exporter → API Proxmox

Todos os clusters Proxmox devem expor métricas através de um exporter dedicado com utilizador read-only (PVEAuditor).

2.3 Blackbox Exporter – ICMP

Tipo: ICMP (ping)

Objetivo: verificar disponibilidade de hosts e gateways

Métricas: latência, perda de pacotes, estado up/down

Uso típico: routers, firewalls, gateways, nós críticos

2.4 Blackbox Exporter – HTTP / HTTPS

Tipo: HTTP / HTTPS

Objetivo: verificar serviços web internos e externos

Validações:

Código HTTP

Tempo de resposta

TLS / certificados

Exemplos: Grafana, Uptime Kuma, aplicações self-hosted

2.5 Uptime Kuma

Tipo: monitorização ativa de serviços

Integração: métricas expostas para Prometheus

Função: redundância e visibilidade operacional complementar

2.6 Logs – Promtail + rsyslog

Serviço: Promtail

Origem dos logs: rsyslog

Protocolo: syslog TCP

Porta: 1514/TCP

Destino final: Loki

Linux
systemctl is-active rsyslog || systemctl status rsyslog

apt update
apt install -y rsyslog
systemctl enable --now rsyslog


Configuração de envio para Promtail:

cat >/etc/rsyslog.d/90-promtail.conf <<'EOF'
# Enviar todos os logs para Promtail
*.* @@192.168.35.6:1514
EOF

systemctl restart rsyslog

OpenWrt
uci set system.@system[0].log_ip='192.168.35.6'
uci set system.@system[0].log_port='1514'
uci set system.@system[0].log_proto='tcp'
uci commit system
/etc/init.d/log restart


Tipos de logs:

Sistema

Serviços

Containers

Aplicações

3. Processamento de Dados
3.1 Prometheus

Responsável por:

Recolha de métricas

Armazenamento em TSDB

Execução de queries (PromQL)

Avaliação de regras de alerta

Utiliza:

scrape_configs

file_sd_configs

Regras de alertas

Retenção configurada no TSDB

3.2 Loki

Ingestão e indexação de logs

Recebe dados exclusivamente via Promtail

Otimizado para correlação com métricas no Grafana

4. Visualização
Grafana

Interface gráfica central da stack.

Inclui dashboards para:

Proxmox

Hosts Linux

Blackbox (ICMP / HTTP)

Logs (Loki)

Provisioning automático de:

Datasources

Dashboards

Alertas (quando aplicável)

5. Alertas
5.1 Alertmanager

Recebe alertas do Prometheus

Aplica:

Routing

Agrupamento

Silenciamento

Deduplicação

5.2 ntfy-relay

Canal final de notificação

Integração via Alertmanager

Envio de alertas para tópicos ntfy

Suporte a:

Prioridades

Labels

Estados (firing / resolved)

6. Fluxo Resumido
Exporters / Logs
        ↓
Prometheus / Loki
        ↓
      Grafana
        ↓
   Alertmanager
        ↓
     ntfy-relay

7. Notas Finais

Stack desenhada para ambientes self-hosted

Compatível com múltiplas VLANs

Preparada para alta disponibilidade