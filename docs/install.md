# Install guide

This is a high-level checklist. See `PCEP_System_Plan.md` for full details.

## Order of operations

1. Stand up DNS first so every host and certificate request resolves correctly.
2. Provision each VPS with the install scripts below.
3. After the hosts and core services are reachable, bring up the WireGuard mesh.

## 1. Home node

1. Install pfSense on the N100.
2. Configure WAN and LAN, set up DHCP.
3. Put Deco mesh into bridge / AP mode.
4. Enable WireGuard and establish a tunnel to VPS2.
5. Configure basic firewall rules (LAN, IOT, DMZ if used).
6. Attach a USB drive and expose a simple SMB/NFS share.
7. Prepare DHCP options for PXE if needed.

## 2. Cloud nodes

1. Provision three VPS instances (VPS1, VPS2, VPS3).
2. Harden SSH and basic firewall rules.
3. Set up WireGuard on VPS2 as the hub; connect VPS1, VPS3, and pfSense.
4. Configure DNS records for your chosen domain.

## 3. Core services

- VPS1:
  - Deploy Mailcow or MIAB.
  - Configure MX, SPF, DKIM, DMARC.

- VPS2:
  - Deploy Caddy, Keycloak, Seafile (or chosen file service), Immich, Joplin
    Server, Baïkal, Forgejo.
  - Wire these behind the reverse proxy and SSO.

- VPS3:
  - Deploy MinIO and restic server.
  - Configure backup jobs from VPS1, VPS2, and home.

## 4. Validation

- Test mail send/receive.
- Test mobile VPN into VPS2 and access home resources.
- Test file sync, photo upload, calendar/contacts, notes, and Git access.
- Test backups and a sample restore.

## Provisioning scripts

All scripts assume Debian/Ubuntu and must be run as root.
From the repository root:

- Bootstrap any VPS with hardened defaults and Docker:
  ```bash
  sudo ./scripts/base-server-setup.sh
  ```

- Stage VPS2 application stack in `/opt/pcep`:
  ```bash
  sudo ./scripts/provision-vps2.sh
  ```

- Stage VPS3 backup stack in `/opt/pcep`:
  ```bash
  sudo ./scripts/provision-vps3.sh
  ```

After copying the compose files, edit `/opt/pcep/.env` and the compose YAMLs
with real hostnames, secrets, and storage paths before running
`docker compose up -d`. The WireGuard mesh can be enabled after DNS and these
base services are online.
