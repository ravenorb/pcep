#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root (sudo -i)."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt update
apt -y upgrade
apt -y install curl git ufw fail2ban wireguard docker.io

if apt-cache show docker-compose-plugin >/dev/null 2>&1; then
  apt -y install docker-compose-plugin
elif apt-cache show docker-compose >/dev/null 2>&1; then
  apt -y install docker-compose
else
  echo "Warning: docker-compose/docker-compose-plugin package not available; install Docker Compose manually."
fi

systemctl enable --now docker

ufw allow OpenSSH
ufw --force enable

cat <<'MSG'
Base packages installed. Next steps:
1) Add your SSH keys and disable password logins.
2) Configure /etc/fail2ban/jail.local as needed.
3) Confirm kernel headers are present before enabling WireGuard.
MSG
