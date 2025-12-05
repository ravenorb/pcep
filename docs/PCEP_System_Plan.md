# Personal Cloud & Edge Platform (PCEP) System Plan

This document presents the complete blueprint for the Personal Cloud & Edge Platform (PCEP).  It explains the goals of the project, enumerates each node and its role, and provides a detailed, step‑by‑step checklist to commission the entire system.  Additional sections cover pfSense configuration, authoritative DNS, PXE booting and sample WireGuard tunnel definitions.  Use this file as the master reference when building and maintaining your private cloud.

## 1. Purpose

The primary goal of PCEP is to **take back control of your data**.  By running your own infrastructure you eliminate reliance on Google, Apple, Dropbox and other cloud vendors, improving privacy and security while retaining convenience.  Services replaced include:

* **File storage & sync** – Seafile provides desktop and mobile file synchronisation with WebDAV/SFTP access for NAS integration.  Immich handles photos and videos with automatic uploads and AI‑powered search.
* **Email** – Mailcow (or Mail‑in‑a‑Box) runs on its own VPS to deliver SMTP/IMAP with spam filtering and webmail.
* **Calendar & contacts** – Baïkal exposes CalDAV and CardDAV so your devices can sync schedules and address books without Google.
* **Notes** – Joplin Server offers end‑to‑end encrypted note synchronisation across your devices.
* **Photos** – Immich replaces Google Photos with private uploads, face and object recognition and shared albums.
* **SSO / identity** – Keycloak acts as a central identity provider so you sign into all services with a single account and can enforce MFA and policies.
* **Git hosting** – Forgejo (a lightweight fork of Gitea) hosts your Git repositories and CI/CD pipelines.
* **Backup & offsite replication** – MinIO plus restic allow secure, deduplicated backups from all nodes with replication to your home NAS.

The system spans **one home node** and **three cloud VPS nodes** connected by a WireGuard VPN mesh.  The home node (pfSense + HAOS) routes and segregates the LAN, while the VPSs provide internet‑facing services, storage and backup.

## 2. System Components

### 2.1 Home Node (pfSense + HAOS)

The home node consists of a dedicated pfSense router (N100 hardware) and a HAOS box (N150 hardware).  It delivers network segmentation, basic storage, and automation services:

* **pfSense router**
  - Routes WAN/LAN traffic and enforces firewall policies.
  - Defines VLANs for LAN, IoT and optional DMZ networks without requiring VLAN‑aware switches.  The Decos remain in bridge mode and pfSense performs segmentation.
  - Runs DHCP on each VLAN, handing out IP addresses and PXE boot options.
  - Establishes a WireGuard tunnel to the edge VPS (VPS2) and optionally to other cloud nodes.
  - Hosts a basic TFTP server and PXE boot environment for provisioning and restore images.  A USB drive connected to pfSense stores ISO and recovery images.  DHCP options 66/67 are set to point to pfSense’s TFTP root.
  - Provides authoritative DNS for your domain (ns1) via the BIND package.  Secondary DNS servers run on the two VPS nodes.

* **HAOS (Home Assistant OS)**
  - Runs Home Assistant for automation, presence, lighting and device control.
  - Hosts Frigate as a local NVR for cameras so video remains on the LAN.
  - Runs a PBX (FreePBX) for local telephony; calls route through a SIP gateway on the cloud.
  - Does **not** host heavy file/cloud applications.  Seafile/Immich/Joplin run on VPS2 to avoid saturating the home uplink.

* **Deco Mesh**
  - Two Deco X25 units inside the house, one X25 in the barn and one X50 on the garage provide Wi‑Fi coverage.
  - All Decos operate in bridge mode and connect via wireless backhaul initially.  Wired backhaul can be added later to improve throughput.

### 2.2 Cloud Node – VPS1 (Mail)

This VPS is dedicated to email.  You may start with Mail‑in‑a‑Box (MIAB) but should plan to standardise on **Mailcow** for production.  Mailcow bundles Postfix, Dovecot, Rspamd, SOGo/Roundcube webmail and implements DKIM, SPF and DMARC.  The VPS stores mail locally for performance and replicates encrypted backups to VPS3 and the home NAS via restic.

### 2.3 Cloud Node – VPS2 (Edge)

The edge node is the central hub for all internet‑facing services:

* **VPN hub** – WireGuard runs here and peers with pfSense, VPS1 and VPS3.  Road‑warrior clients also connect to VPS2.  This node routes traffic between sites without exposing the home IP.
* **Reverse proxy** – Caddy or Traefik terminates TLS (Let’s Encrypt) and proxies traffic to internal services.  It also handles the landing page and dashboards.
* **Identity provider** – Keycloak provides OIDC and SAML for SSO across all services.
* **Seafile** – Lightweight file synchronisation engine with WebDAV support.  Users can mount shared libraries via SMB/NFS on the LAN using a local NAS share.
* **Immich** – AI‑powered photo and video management.  Mobile clients upload photos directly to VPS2.  Backups replicate to VPS3 and your home NAS.
* **Baïkal** – A simple CalDAV/CardDAV server for calendars and contacts.
* **Joplin Server** – Encrypted note synchronisation for Joplin clients.
* **Forgejo** – Git hosting with Gitea‑style web UI.  Stores install scripts, automation code and infrastructure definitions.

All services authenticate against Keycloak and run in Docker containers defined in [`compose/vps2-docker-compose.yml`](../compose/vps2-docker-compose.yml).

### 2.4 Cloud Node – VPS3 (Backup)

VPS3 houses the backup and replication infrastructure:

* **MinIO** – Provides S3‑compatible object storage for restic repositories.  Each service (mail, seafile, immich, etc.) writes encrypted snapshots to dedicated buckets.
* **restic server** – Optionally runs restic’s stateless server for direct backups.
* **Forgejo mirror** – Mirrors your repositories for redundancy.
* **Backup scripts** – Cron jobs orchestrate snapshots and offsite syncs.  Snapshots replicate both to this node and to the home NAS.

### 2.5 Domain & DNS

Choose a short, memorable domain name with matching `.com` and `.net` (for example, `vexlo.com` / `vexlo.net`).  pfSense operates the primary authoritative DNS server (ns1) and both VPS1 and VPS2 run secondary name servers (ns2/ns3).  Once your name servers are in place you can transfer DNS management away from Wix.

### 2.6 Backup & Failover Strategy

The system uses **restic** for backups and **MinIO** for storage.  Each service writes deduplicated, encrypted snapshots to MinIO buckets on VPS3.  Cron tasks pull those snapshots to the home NAS, providing an on‑prem mirror.  In the event of a VPS outage, the home NAS can start Seafile and Immich containers using replicated data, ensuring continued access to files and photos even when the cloud is down.

## 3. Installation Checklist

The following checklist acts as a build plan.  Work through it sequentially; each section builds on the previous one.  Tick off items as you complete them.

### Section A — Home Network Setup

1. **Commission pfSense:**
   * Unbox and install pfSense on the N100 appliance.  Upgrade to the latest pfSense CE/Plus release.
   * Define interfaces: WAN (internet), LAN (Deco), OPT1 (HAOS admin/PXE/NAS) and OPT2 (optional DMZ).
   * Create subnets without requiring VLAN‑aware switches: assign separate IPv4 ranges to LAN, IoT and DMZ and enforce segmentation through firewall rules.  Example ranges: `10.10.10.0/24` for LAN, `10.10.20.0/24` for IoT.
   * Enable DHCP on each subnet and specify TFTP/boot options (option 66/67) for future PXE clients.
   * Disable router mode on the Deco mesh and configure it to bridge mode; connect its uplink port to the LAN interface of pfSense.

2. **Setup WireGuard tunnel (pfSense → VPS2):**
   * Install the WireGuard package on pfSense.
   * Generate key pairs and configure an interface (e.g. `wg0`) with address `10.100.0.2/24`.
   * Add a peer for VPS2, specifying the remote public key and endpoint (port 51820).  Set allowed IPs to the cloud subnets (e.g. `10.200.0.0/16`).
   * On VPS2, create a matching peer for pfSense with its public key and allowed IP `10.100.0.2/32`.
   * Apply NAT and firewall rules on pfSense to allow UDP port 51820 and route the VPN traffic.
   * Confirm handshake and connectivity between pfSense and VPS2.

3. **Configure PXE:**
   * Install the TFTP server package on pfSense (or use the built‑in TFTP functionality).  Point the TFTP root to a directory on the USB storage.
   * Upload netboot files (e.g. `pxelinux.0`, `memdisk`, `iPXE`) and ISO images to the TFTP directory.
   * Set DHCP options 66 and 67 to the pfSense LAN IP and the boot file (`pxelinux.0`).
   * Test booting a client on the LAN to ensure it downloads and runs the bootloader.

4. **Enable USB NAS:**
   * Attach a USB drive to the pfSense box, format it (UFS/ext4) and mount it under `/mnt/USB` or a similar path.
   * Enable the `services → NFS` or `services → CIFS/SMB` package to export shares for backups and PXE files.  Use minimal traffic – this is a convenience store, not your primary NAS.

5. **HAOS installation and services:**
   * Provision Home Assistant OS on the N150 hardware with two Ethernet interfaces.  Connect one interface to the LAN network for general access and the other to the OPT1 interface on pfSense for management and PXE integration.
   * Install the Frigate add‑on with appropriate camera configuration.  Configure recording to the HAOS disk or your USB share.
   * Install the FreePBX add‑on for local telephony.  Configure a SIP trunk to route external calls through the cloud PBX gateway on VPS2 (to be configured later).
   * Keep heavy cloud services off of HAOS to avoid saturating your home uplink.

### Section B — Cloud Node Setup

#### B1. VPS1 (Mail Node)

1. Deploy Mailcow using its official installer on VPS1.  Alternatively, if you currently run Mail‑in‑a‑Box (MIAB), plan a migration.
2. Configure DNS (MX, SPF, DKIM, DMARC) for your chosen domain pointing to this node.
3. Test SMTP/IMAP/webmail access and ensure spam filtering works.
4. Setup restic backup scripts to push encrypted snapshots of the maildir and configuration to MinIO on VPS3 and replicate them to your home NAS.

#### B2. VPS2 (Edge Node)

1. **VPN hub:** Install and configure WireGuard.  Assign IP `10.100.0.1/24`.  Create peers for pfSense (`10.100.0.2/32`), VPS1 (`10.100.0.3/32`) and VPS3 (`10.100.0.4/32`).  Enable IP forwarding.
2. **Reverse proxy:** Deploy Caddy (preferred for ease of configuration) or Traefik.  Create a `Caddyfile` defining subdomains for each service, enabling automatic HTTPS via Let’s Encrypt.  Example subdomains: `auth.yourdomain.com`, `files.yourdomain.com`, `photos.yourdomain.com`, `notes.yourdomain.com`, `git.yourdomain.com`, `dav.yourdomain.com`.
3. **Identity provider:** Run Keycloak in Docker, backed by a Postgres database.  Set the realm (e.g. `home-cloud`) and configure clients for Seafile, Immich, Baïkal, Joplin and Forgejo.  Enable OIDC for each service.  Protect the Keycloak admin console behind a strong password and enable MFA.
4. **Seafile:** Deploy the Seafile Docker image.  Store the `seafile-data` volume on VPS2’s disk.  Configure Seafile to authenticate via Keycloak using OIDC.  Expose it on `files.yourdomain.com` via Caddy.
5. **Immich:** Deploy the Immich server and database.  Configure storage volumes for uploads.  Integrate with Keycloak for login.  Expose it on `photos.yourdomain.com`.  Schedule restic snapshots to back up the upload folder to MinIO on VPS3.
6. **Joplin Server:** Run the official Joplin server in a container.  Back it with Postgres and configure it to use Keycloak.  Expose on `notes.yourdomain.com`.  Add restic backups of the `~/.joplin` directory and database.
7. **Baïkal:** Deploy Baïkal in an Nginx container.  Set up admin credentials.  Expose on `dav.yourdomain.com` via Caddy.  Connect to Keycloak if desired or use HTTP basic auth.
8. **Forgejo:** Install Forgejo via Docker.  Persist the `/data` volume on VPS2.  Configure OIDC with Keycloak.  Use Forgejo to store this repository (`PCEP`) and other automation scripts.  Mirror the repository to VPS3 for redundancy.
9. **Testing:** For each service, log in via Keycloak, upload/test content and verify TLS termination through the reverse proxy.

#### B3. VPS3 (Backup Node)

1. Deploy MinIO in a Docker container.  Set up the MinIO root user and password.  Create buckets (`seafile-backup`, `immich-backup`, `mail-backup`, `notes-backup`, etc.).  Expose the console on port 9001.
2. Deploy the restic rest-server if you prefer an HTTP endpoint for backups.  Alternatively, use the MinIO S3 API directly.
3. Install Forgejo (optional) and mirror repositories from VPS2 for redundancy.
4. Write and schedule backup scripts (cron or systemd timers) on VPS1, VPS2 and VPS3 to push snapshots to MinIO.  Use restic’s retention policies to prune old backups.
5. Configure replication scripts on your home NAS to pull buckets from VPS3 nightly so you maintain an offline mirror.

### Section C — Cross‑System Integration

1. **DNS configuration:**
   * Register your new domain(s) and set the authoritative name servers to your own.  For example, `ns1.yourdomain.com` → pfSense home IP, `ns2.yourdomain.com` → VPS1, `ns3.yourdomain.com` → VPS2.
   * Install the BIND package on pfSense and create a master zone file for your domain.  Include SOA and NS records pointing to all three name servers.  Add A/AAAA records for each service subdomain.
   * Configure BIND on VPS1 and VPS2 as slaves.  Point them to pfSense as the master for zone transfers.
2. **VPN mesh:**
   * Connect VPS1 and VPS3 to VPS2 via WireGuard using the configuration templates in `wireguard/`.  Assign addresses `10.100.0.3/24` and `10.100.0.4/24` respectively.
   * Confirm that VPS1 ↔ VPS3 traffic routes through VPS2 and that pfSense can reach both nodes across the tunnel.
3. **Git deployment:**
   * Initialise a repository for PCEP in Forgejo on VPS2 and push the contents of this repo.  Set up a mirror on VPS3.
   * Use this repo to version control your Ansible playbooks, Docker Compose files, scripts and documentation.

### Section D — Failover & Replication

1. **Configure restic replication:**
   * Schedule restic snapshots on each service container (Seafile, Immich, Joplin, mail) to back up their data directories to MinIO on VPS3.
   * On your home NAS (USB storage for now), configure a cron job to pull the S3 buckets from MinIO using the AWS CLI or rclone.  Store them in an encrypted format.

2. **Prepare local failover:**
   * Install Docker on your home NAS or a spare Linux box.  Copy the `compose` files to this node.
   * In the event of a cloud outage, start the Seafile and Immich services locally using the replicated data.  Update your Caddyfile or pfSense DNS entries to point `files.yourdomain.com` and `photos.yourdomain.com` to your home IP while the cloud recovers.

3. **Test restoration:**
   * Periodically restore a restic snapshot on a test machine to validate your backups.
   * Document the steps for a full mail restore, Seafile library restore and Immich restore in your Git repo.

### Section E — Final Validation

1. Test mail flow end‑to‑end (external → mail server → IMAP client).  Check spam filtering and DMARC reports.
2. Sync calendar and contacts on mobile and desktop using Baïkal.  Add, edit and delete entries to ensure bidirectional sync.
3. Perform file sync using Seafile clients.  Create shared libraries, upload files and mount them on the LAN as SMB/NFS shares via your NAS.
4. Install the Immich mobile app, upload photos and verify AI tagging/search and album sharing.  Check replication to backups.
5. Sync notes with Joplin on multiple devices.  Test encryption and conflict resolution.
6. Clone your Git repo from Forgejo, make changes and push.  Verify the mirror on VPS3 updates.
7. Connect road‑warrior devices to the VPN hub on VPS2.  Confirm access to LAN resources and internet break‑out if configured.
8. Simulate a cloud outage by shutting down a VPS.  Fail over to the home instance and confirm continued access to critical data.  Restore the VPS and confirm replication catches up.

## 4. Additional Notes

### 4.1 pfSense Setup without VLAN‑Aware Switches

Because you do not have VLAN‑aware switches, the pfSense router uses multiple physical interfaces and firewall rules to segregate networks.  The Deco mesh operates in bridge mode, passing traffic to pfSense.  If you later deploy managed switches, you can trunk VLANs and simplify cabling; the logical configuration inside pfSense remains valid.

### 4.2 Running Your Own DNS Authority

pfSense runs the BIND package to serve as the primary (master) name server.  Two secondary name servers run on VPS1 and VPS2.  To set this up:

1. Install the BIND package on pfSense and create a zone file for your domain with proper SOA, NS, A, AAAA and CNAME records.  Keep serial numbers updated when you make changes.
2. On VPS1 and VPS2, install BIND or use the `named` container.  Configure them as slaves for the zone, specifying pfSense’s public IP as the master.  Enable zone transfers.
3. At your registrar, update the name servers for your domain to point to `ns1.yourdomain.com` (pfSense), `ns2.yourdomain.com` (VPS1) and `ns3.yourdomain.com` (VPS2).

### 4.3 Full PXE on pfSense

While pfSense is not a full NAS, it can host a complete PXE environment for basic provisioning.  Use the TFTP server package and store boot loaders and ISO images on an attached USB drive.  For convenience you can also host an iPXE script that chains to cloud or local installers.  When your infrastructure grows, migrate PXE duties to a dedicated PXE/MDM server on your home LAN but keep pfSense’s DHCP options pointing clients to the correct TFTP server.

### 4.4 WireGuard Config Templates

Sample configuration for VPS2 (hub):

```ini
[Interface]
Address = 10.100.0.1/24
PrivateKey = <VPS2_PRIVATE_KEY>
ListenPort = 51820

# pfSense peer
[Peer]
PublicKey = <PFSENSE_PUBLIC_KEY>
AllowedIPs = 10.10.0.0/16, 10.100.0.2/32

# VPS1 peer
[Peer]
PublicKey = <VPS1_PUBLIC_KEY>
AllowedIPs = 10.100.0.3/32

# VPS3 peer
[Peer]
PublicKey = <VPS3_PUBLIC_KEY>
AllowedIPs = 10.100.0.4/32
```

On pfSense, create an interface `wg0` with address `10.100.0.2/24` and set the peer to VPS2’s public key and endpoint.  Add static routes for cloud subnets to `wg0`.  Similarly, configure peers on VPS1 and VPS3.

---

This document should serve as the authoritative reference for building and managing your Personal Cloud & Edge Platform.  As you implement and refine the system, update this file and commit your changes to the Git repository.  If you need to generate a PDF or other formats, convert this Markdown using `pandoc` or your favourite tool.
