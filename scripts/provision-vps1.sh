#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root (sudo -i)."
  exit 1
fi

TARGET_DIR=/opt/pcep
MAILCOW_DIR="${TARGET_DIR}/mailcow-dockerized"

mkdir -p "${TARGET_DIR}"

if [[ ! -d "${MAILCOW_DIR}" ]]; then
  git clone https://github.com/mailcow/mailcow-dockerized "${MAILCOW_DIR}"
else
  echo "mailcow-dockerized already present at ${MAILCOW_DIR}; skipping clone."
fi

cd "${MAILCOW_DIR}"

cat <<'MSG'
VPS1 baseline ready for Mailcow.
- Run ./generate_config.sh to set your mail domain, timezone, and other defaults.
- Review and adjust mailcow.conf to ensure hostnames and IPs are correct.
- Once ready, run: docker compose pull && docker compose up -d
MSG
