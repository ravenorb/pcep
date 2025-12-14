# Backup & Replication

This directory contains scripts and guidance to set up secure,
encrypted backups using **restic** and **MinIO**. MinIO provides an
on-premise S3-compatible storage service, while restic performs
deduplicated, encrypted snapshots.

## Setup Summary

1. **Deploy MinIO on VPS3:**
   * Use the compose file in `compose/vps3-docker-compose.yml` to run
     MinIO.
   * Access the console on `http://<vps3-ip>:9001` and create buckets
     for each service: `mail-backup`, `seafile-backup`, `immich-backup`,
     `notes-backup`, etc.
2. **Initialise restic repositories:**
   * On each host (VPS1, VPS2, VPS3, pfSense/HAOS) install restic.
   * Export `RESTIC_REPOSITORY=s3:http://<vps3-ip>:9000/<bucket-name>`
     and `RESTIC_PASSWORD=<your-strong-password>`.
   * Run `restic init` to create the repository in each bucket.
3. **Create backup scripts:**
   * For each service container, identify directories to back up (for
     example `/srv/seafile/seafile-data`, `/usr/src/app/upload` for
     Immich, `/var/lib/mysql` for mail).
   * Write a shell script that stops the container (if necessary), runs
     restic, and prunes old snapshots. Example:

   ```bash
   #!/bin/bash
   export RESTIC_REPOSITORY=s3:http://vps3:9000/seafile-backup
   export RESTIC_PASSWORD=changeme
   restic backup /opt/seafile/seafile-data
   restic forget --prune --keep-last 7 --keep-weekly 4 --keep-monthly 6
   ```

   * Schedule the script with `cron` or a systemd timer.
4. **Replicate backups to home NAS:**
   * On your home NAS, install the AWS CLI or `rclone`.
   * Use a cron job to mirror each MinIO bucket to local storage.
     Example using `rclone`:

   ```bash
   rclone sync s3:minio/seafile-backup /mnt/nas/backups/seafile \
     --s3-endpoint http://vps3:9000 --progress
   ```

5. **Test restore:**
   * Periodically run `restic restore` into a temporary directory to
     ensure your backups are valid and complete.

## Additional Notes

* The `backup` directory may contain example scripts (to be created as
  you refine your deployment). Commit your actual scripts here for
  version control.
* Restic supports incremental backups, compression, and encryption.
  MinIO supports versioning and replication if you decide to run a second
  MinIO instance at home.
