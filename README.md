# home-server

Setting up Proxmox and deploying [things](./dietpi-base-vm/) to it.

## Storage 
Create a RAID-Z1 ZFS pool `zpool create media-tank raidz /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ2G9X7 /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ2GBC8 /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ4061G`

Creates a mount point at `/media-tank`

### Add new disks 
`zpool add media-tank raidz /dev/disk/by-id/ata-ST8000VN004-3CP101_WP01JPTQ /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ64L5F /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZ669S4`

- Don't format the disks before hand!

## SSH CloudFlared
Created a tunnel using `cloudflared`, https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/#connect-to-ssh-server-with-cloudflared-access
- Install on the target (e.g. Proxmox)
- Install on the client
- `nano ~/.ssh/config` on the client:
```
Host sshpm.munyard.dev
ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
```
## SSH Tailscale
Tailscale creates a private virtual network (backed by WireGuard) that gives connected devices an IP address they can reach each other by. 

- Install Tailscale to give the device an internet accessible IP address that is routed via the Tailscale VPN https://tailscale.com/kb/1031/install-linux
