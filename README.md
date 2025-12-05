# Personal Cloud & Edge Platform (PCEP)

Welcome to the **Personal Cloud & Edge Platform (PCEP)** repository.  This project documents and orchestrates a distributed self‑hosted solution designed to replace third‑party cloud services (Google Drive/iCloud/Photos/Calendar/Notes/GitHub/etc.) with a secure and private system under your control.

The repository contains documentation, configuration files and automation scripts to build, deploy and maintain a multi‑node private cloud composed of a home gateway and a trio of VPSs.  Together, these nodes provide email, files, photos, calendar/contacts, notes, Git hosting, identity (SSO), backup, monitoring and remote access via VPN.

## Repository structure

* `docs/` – Architectural and operational documentation written in Markdown.
* `compose/` – Docker Compose files for deploying services on the VPS nodes.
* `wireguard/` – Example WireGuard configuration templates for VPN tunnels.
* `pfSense/` – Guidance for configuring the home pfSense router, including DHCP, DNS, PXE and NAS roles.
* `dns/` – Example BIND zone files and instructions for running your own authoritative DNS.
* `backup/` – Scripts and guidance for setting up MinIO and restic for encrypted backups and replication.

Please refer to `docs/PCEP_System_Plan.md` for the complete architecture and step‑by‑step installation checklist.
