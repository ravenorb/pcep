# Personal Cloud & Edge Platform (PCEP)

![PCEP Logo](logo/pcep-logo.svg)

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-alpha-orange.svg)]()
[![Docs](https://img.shields.io/badge/docs-view%20docs-success)](docs/index.md)

PCEP is a self-hosted personal cloud and edge platform. It replaces third-party
cloud services (Google Drive / iCloud / Photos / Calendar / Notes / GitHub, etc.)
with a stack you control:

- Home gateway and services on **pfSense + Home Assistant OS (HAOS)**
- Three VPS nodes providing **mail**, **files**, **photos**, **calendar/contacts**,
  **notes**, **Git hosting**, **identity (SSO)**, **backup**, and **VPN access**

The design is **scriptable, repeatable, and portable** so you can rebuild or
deploy it as a productized system.

## Repository structure

- `docs/` – Architectural and operational documentation.
- `compose/` – Docker Compose files for deploying services on VPS nodes.
- `wireguard/` – Example WireGuard configuration templates.
- `pfSense/` – pfSense configuration guidance for DHCP, DNS, PXE, NAS roles.
- `dns/` – Example BIND zone files and authoritative DNS notes.
- `backup/` – MinIO and restic backup/replication docs and scripts.
- `.github/` – Actions workflows, issue templates, PR template, project meta.
- `logo/` – SVG logo and visual assets.

## Quick start

1. Read `docs/architecture.md` for the high-level design.
2. Follow `docs/install.md` for a step-by-step deployment path.
3. Use the `compose/` files on VPS2 and VPS3 to bring up services.
4. Configure pfSense using `pfSense/setup.md`.
5. Wire up SSO, DNS, and VPN as described in `docs/services.md`.

## Contributing

Contributions are welcome as this platform grows. See:

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

## Security

If you find a security issue, please follow the process in:

- [SECURITY.md](SECURITY.md)
