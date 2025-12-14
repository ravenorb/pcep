# Services overview

## Identity

- **Keycloak** on VPS2 provides OIDC for Seafile, Immich, Joplin, Forgejo,
  and future services.

## DNS

- **PowerDNS Authoritative** on VPS2 (`edge.neacnc.com` /
  `67.217.246.23`) publishes public zones for `neacnc.com` and
  `elitecncservices.com` and sends NOTIFY/AXFR to secondaries.
- **PowerDNS Admin** on VPS2 provides a web UI and API client for managing
  zones, records, and keys.
- **Mailcow (VPS1)** at `cow.neacnc.com` (`74.208.155.223`) runs as a
  secondary DNS target, receiving AXFRs from the VPS2 master so mail and DNS
  stay aligned.

## Files and photos

- **Seafile** (or alternative) handles file sync and sharing.
- **Immich** handles photos and videos, especially mobile camera uploads.

## Mail

- **Mailcow** or **MIAB** on VPS1 provides SMTP, IMAP, and webmail.

## Notes

- **Joplin Server** on VPS2 provides encrypted note sync across devices.

## Calendar and contacts

- **Baïkal** on VPS2 provides CalDAV and CardDAV.

## Git hosting

- **Forgejo** on VPS2 hosts infrastructure code, configs, and docs.

## Backups

- **MinIO** on VPS3 stores encrypted restic snapshots from:
  - VPS1, VPS2, and Home node.
- Home can pull from MinIO for offline restore and failover.
