# pfSense Setup Guide

This guide summarises how to configure your pfSense home router for the PCEP environment without VLAN‑aware switches.  It covers interface assignments, network segmentation, DHCP, DNS, PXE and basic NAS functionality.

## Hardware

- pfSense running on an N100 appliance (4×2.5 GbE).  One port is used for the WAN uplink, one for the LAN (Deco mesh), one for HAOS management/PXE and one spare for an optional DMZ.
- HAOS server (N150) with two Ethernet ports (LAN and management) and a Wi‑Fi adapter.
- Deco mesh in bridge mode providing Wi‑Fi coverage across the property.

## Interface Assignment

| Interface | Role                 | Example IP range | Notes                           |
|----------:|---------------------|-----------------|--------------------------------|
| WAN       | ISP connection      | dynamic        | Obtained from your ISP         |
| LAN       | Primary network     | 10.10.10.0/24  | Uplink to Deco switch/mesh      |
| OPT1      | Management/PXE/NAS | 10.10.50.0/24  | Direct link to HAOS & PXE server |
| OPT2      | DMZ (optional)      | 10.10.40.0/24  | Reserved for future use        |

Because you do not have VLAN‑capable switches, segmentation is enforced via separate physical ports and firewall rules.  The Deco mesh is connected to the LAN interface and operates purely as an access point.

## DHCP

- Enable DHCP service on each internal interface (LAN, OPT1, OPT2).
- For PXE clients on LAN, set DHCP options:
  - **Option 66:** IP address of pfSense’s LAN interface
  - **Option 67:** PXE boot file (e.g. `pxelinux.0`)
- Reserve static leases for infrastructure devices such as HAOS, cameras and servers.

## DNS (Authoritative)

1. Install the **BIND** package via pfSense’s package manager.
2. Create a primary zone for your chosen domain (e.g. `mydomain.com`).
3. Set NS records: `ns1.mydomain.com` (pfSense), `ns2.mydomain.com` (VPS1) and `ns3.mydomain.com` (VPS2).
4. Define A/AAAA records for all services (mail, auth, files, photos, notes, git, dav, etc.).
5. Allow zone transfers to the secondary servers (VPS1 and VPS2).
6. At your registrar, delegate your domain to `ns1`, `ns2` and `ns3`.  pfSense now acts as the master DNS authority.

## PXE Boot

pfSense can serve PXE clients using its TFTP server:

1. Install the **TFTP server** package.
2. Attach a USB drive to pfSense, mount it (e.g. `/mnt/USB`) and create a `tftpboot` directory.
3. Upload bootloaders (`pxelinux.0`, `memdisk`, iPXE binaries) and OS installer ISOs into `tftpboot`.
4. Configure DHCP options 66 and 67 as mentioned above.  PXE clients will download the boot file from pfSense and load installer images from the USB drive.
5. When you later move PXE to a dedicated server or NAS, update the DHCP options accordingly.

## WireGuard VPN

See `wireguard/pfsense.conf` for an example of the WireGuard configuration.  Create an interface (`wg0`), assign it to an OPT interface, and configure peers for VPS2.  Add static routes for your cloud subnets (e.g. `10.200.0.0/16`) pointing to `wg0`.  Allow UDP 51820 inbound on the WAN and create firewall rules permitting traffic from `wg0` to the LAN and vice versa as needed.

## USB NAS

Although pfSense is not designed as a full NAS, you can export simple file shares:

1. Format your USB drive with UFS or ext4 and mount it under `/mnt/USB`.
2. Install the **NFS** or **Samba** package.
3. Export minimal shares for PXE images and ad‑hoc backups.  This should not be used for high‑throughput file storage; a dedicated NAS or home server is recommended for that.

## Notes

- The HAOS box connects its first Ethernet port to the LAN network and its second port to OPT1.  Use the OPT1 connection for administrative access, PXE imaging and NAS access.
- The Wi‑Fi adapter in the HAOS box is unused; it can be configured as a Wi‑Fi client if needed to join the LAN.
- When you later migrate to managed switches, you can trunk VLANs and run everything on fewer physical cables.  The pfSense configuration remains valid; only the switch ports need reconfiguration.
