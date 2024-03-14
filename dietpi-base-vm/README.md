# Create slim base VM
Create a new VM in Proxmox by following the instructions: [https://dietpi.com/docs/install/#how-to-install-dietpi](https://dietpi.com/docs/install/#__tabbed_1_5)

- Install docker-engine https://docs.docker.com/engine/install/debian/
- Install and run dockage https://github.com/louislam/dockge?tab=readme-ov-file#basic

`dockage user: bethany, password in 1Password` runs on :5001

Start the VM, get it's IP, then run the following from Thushan's repository https://github.com/thushan/proxmox-vm-to-ct

```sh
./proxmox-vm-to-ct.sh --source 192.168.1.32 \
                      --target diet-pi-base-image \
                      --storage local-lvm \
                      --default-config-containerd
```

base image password: 1Password 'diet pi password'

This will show up as a new lxc in Proxmox. 
- Clone it
- Edit the lxc conf in Proxmox (`/etc/pve/lxc/<id>.conf`
- Paste this in [lxc.conf](../plex/lxc.conf)

Start it then deploy Plex using Dockage with [docker-compose.yml](../plex/docker-compose.yml)

Plex requires browser on same subnet to trigger setup. Create an SSH tunnel: `ssh -L 8888:127.0.0.1:32400 192.168.1.36 -l root`, then go to localhost:8888/web. 
- `8888` is the port binding for the SSH tunnel)
- `32400` is the port Plex is running on inside container
- `192.168.1.36` is the IP of the Plex host
