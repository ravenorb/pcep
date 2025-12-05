# Architecture

PCEP is split into:

- **Home node** – pfSense router, Home Assistant OS (HAOS), local services, PXE, and local storage.
- **Cloud nodes** – three VPS instances for mail, edge services, and backup/replication.
- **VPN mesh** – WireGuard tunnels linking home and cloud.
- **Identity and DNS** – Keycloak for SSO, self-hosted DNS for public domains.

## Roles

- **VPS2 (Edge hub)**: reverse proxy, SSO, VPN termination, file and notes services.
- **VPS1 (Mail node)**: Mailcow (or MIAB) for SMTP/IMAP and webmail.
- **VPS3 (Backup node)**: MinIO and restic repositories, monitoring, and ops tools.
- **Home**: Home Assistant, Frigate, PBX, PXE, and local storage / failover.

See `PCEP_System_Plan.md` for the long-form description and sequence diagrams.
