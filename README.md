# home-server

Setting up Proxmox and deploying [things](./dietpi-base-vm/) to it.

# Proxmox host things
Create a RAID-Z1 ZFS pool `zpool create media-tank raidz /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ2G9X7 /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ2GBC8 /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ4061G`

Creates a mount point at `/media-tank`
