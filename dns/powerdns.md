# PowerDNS Authoritative + PowerDNS Admin

This stack runs on VPS2 and manages public zones for the platform
(`neacnc.com` and `elitecncservices.com`). Mailcow on VPS1 consumes
zone transfers as a secondary so DNS stays available alongside mail
services.

## Components

- **pdns-authoritative** – PowerDNS Authoritative server using the gmysql
  backend.
- **pdns-auth-db** – MariaDB backing store for zones and records.
- **pdns-admin** – Web UI and API client for PowerDNS.
- **pdns-admin-db** – MariaDB database for PowerDNS Admin.

## Ports

- `53/tcp` and `53/udp` – Authoritative DNS service.
- `8081` – PowerDNS API and webserver (internal; front with Caddy
  if publishing).
- `9191` – PowerDNS Admin HTTP UI (put behind Caddy/HTTPS in production).

## Deploy on VPS2

1. Copy `compose/vps2-docker-compose.yml` to VPS2 and set real secrets
   for `PDNS_api_key`, `SECRET_KEY`, database passwords, and
   `PDNS_allow_axfr_ips` (already prefilled with the VPS1 public IP
   `74.208.155.223`).
2. Bring up the stack:
   `docker compose -f vps2-docker-compose.yml up -d pdns-authoritative
   pdns-auth-db pdns-admin pdns-admin-db`.
3. Log into PowerDNS Admin at `https://pdns-admin.edge.neacnc.com`
   (behind Caddy). Create the initial admin user, set the API key to match
   `PDNS_api_key`, and add zones/records.

## Configure Mailcow (VPS1) as secondary

Mailcow ships with PowerDNS; configure it to follow the VPS2 master:

1. Add the VPS2 public IP `67.217.246.23` to Mailcow's PowerDNS allow
   list and set `slave=yes` per the Mailcow DNS documentation (for
   example via `data/conf/pdns.d/secondary.conf`).
2. In PowerDNS Admin, confirm that VPS1's IP `74.208.155.223` is in the
   AXFR/NOTIFY allow list (already set in the compose file) so transfers
   and NOTIFYs are accepted.
3. Create zones and enable automatic secondaries so Mailcow receives
   AXFR and NOTIFY updates from VPS2.

### Seed records to create first

Add these core A/AAAA records first so the infrastructure hostnames resolve:

- `edge.neacnc.com` → `67.217.246.23`
- `cow.neacnc.com` → `74.208.155.223`
- `arc.neacnc.com` → `216.250.115.210`
- Create matching `edge`, `cow`, and `arc` records in `elitecncservices.com`
  if you want mirrored naming.

Test by creating a record in PowerDNS Admin and verifying it appears on the
Mailcow DNS instance after a NOTIFY/AXFR cycle.
