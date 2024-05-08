# home-server

Setting up Proxmox and deploying [things](./dietpi-base-vm/) to it.

## Storage 
Create a RAID-Z1 ZFS pool `zpool create media-tank raidz /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ2G9X7 /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ2GBC8 /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ4061G`

Creates a mount point at `/media-tank`

## SSH
Created a tunnel using `cloudflared`, https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/#connect-to-ssh-server-with-cloudflared-access
- Installed directly on Proxmox host
- `~/.ssh/config` on the client:
```
Host sshpm.munyard.dev
ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
```
**Requires cloudflared on the client. 
