# Install guide

This is a high-level checklist. See `PCEP_System_Plan.md` for full details.

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
