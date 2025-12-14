#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root (sudo -i)."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt update
apt -y upgrade
apt -y install curl git ufw fail2ban wireguard docker.io docker-compose-plugin

systemctl enable --now docker

ufw allow OpenSSH
ufw --force enable

cat <<'MSG'
Base packages installed. Next steps:
1) Add your SSH keys and disable password logins.
2) Configure /etc/fail2ban/jail.local as needed.
3) Confirm kernel headers are present before enabling WireGuard.
MSG
