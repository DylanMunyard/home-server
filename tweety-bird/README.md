# Connect to VPN 
Clone our [base container](../dietpi-base-vm/README.md)

Edit lxc conf `/etc/pve/lxc` and add 

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir
```

## Connecting to VPN
Follow [These Instructions](https://github.com/hsand/pia-wg).  (`apt install git python3 python3-venv wireguard openresolv`)

### (OBSOLETE) Using OpenVPN

Follow [PIA instructions](https://helpdesk.privateinternetaccess.com/kb/articles/linux-setting-up-manual-openvpn-connection-through-the-terminal#anchor-1) up to step 5
- `apt-get install openvpn unzip`
- `cd /etc/openvpn`
- `wget https://www.privateinternetaccess.com/openvpn/openvpn.zip`
- `unzip openvpn.zip`

Edit `au_sydney.ovpn` and change the line `auth-user-pass` to
- `auth-user-pass /etc/openvpn/login.conf`
- Create `/etc/openvpn/login.conf` under `/etc/openvpn` and enter the PIA username and password:

```
<pia_user>
<pia_password>
```

Connect to the VPN `openvpn au_sydney.ovpn`

Create `/etc/systemd/system/openvpn-au-sydney.service` and paste:

```
[Unit]
Description=OpenVPN au_sydney service
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/au_sydney_auth.ovpn

# Restart on failure
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

- `systemctl daemon-reload` ensures new service is detected
- `systemctl start openvpn-au-sydney.service` starts the service immediately
- `systemctl enable openvpn-au-sydney.service` enables the service on boot
