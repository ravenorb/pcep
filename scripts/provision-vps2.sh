#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root (sudo -i)."
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR=/opt/pcep

mkdir -p "${TARGET_DIR}/compose"
cp "${REPO_ROOT}/compose/vps2-docker-compose.yml" "${TARGET_DIR}/compose/"

install -d "${TARGET_DIR}/config"

cat <<'MSG'
VPS2 baseline ready.
- Edit ${TARGET_DIR}/compose/vps2-docker-compose.yml with real domain names and secrets.
- Create ${TARGET_DIR}/.env with credentials for Caddy, Keycloak, Seafile, etc.
- Once ready, run: cd ${TARGET_DIR}/compose && docker compose -f vps2-docker-compose.yml up -d
MSG
