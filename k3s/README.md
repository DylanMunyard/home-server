# Kubernetes manifests

## Custom name resolving
Allows resolving the hosts defined in [ingress.yml](./ingress/ingress.yml)

Install and configure dnsmasq https://wiki.archlinux.org/title/Dnsmasq

edit /etc/resolv.conf:

```conf
# cat /etc/resolv.conf                                                                                                                                  nameserver ::1
nameserver 127.0.0.1
options trust-ad
```

edit (uncomment / add) these options in /etc/dnsmasq.conf:

```conf
listen-address=::1,127.0.0.1
# CloudFlare's nameservers, for example
server=1.1.1.1
server=1.0.0.1
no-resolv
address=/home.net/192.168.1.215 # will resolve *.home.net to k3s 
```

Then prevent /etc/resolv.conf being overwritten by NetworkManager

https://wiki.archlinux.org/title/Domain_name_resolution#Overwriting_of_/etc/resolv.conf

## Building k3s agents
# DietPi k3s agents
k3s server is running on Proxmox host. 

Each Raspberry Pi is a k3s agent running DietPi as the OS.

1. Follow instructions https://dietpi.com/docs/install/ to install Diet Pi on an SD card. 
2. With SD card still mounted, edit (on the SD Card) /boot/cmdline.txt and add ` cgroup_memory=1` to the end of the options
3. Replace /boot/dietpi.txt with [dietpi.txt](dietpi.txt), then make the following edits:

- Replace AUTO_SETUP_NET_HOSTNAME with a unique hostname
- Replace PUT_THE_K3S_SERVER_TOKEN_HERE for `SOFTWARE_K3S_EXEC` with the k3s server token 
(grab the server token from Proxmox host `cat /var/lib/rancher/k3s/server/token`)
- Replace SUPER_SECRET_PASSWORD_HERE with a strong password for AUTO_SETUP_GLOBAL_PASSWORD. This will be the password to use when you ssh in (username is root)

Once you do this, insert the SD Card into the Pi and it should auto-connect to the cluster. You will need to SSH in to kick off the install process (TODO find a way to automate this).


## Flux CD (Obsolete)
This folder is being monitored by [Flux CD](https://fluxcd.io/flux/installation/bootstrap/github/). Edit the manifests in Git and they will be automatically deployed. 

```sh
flux bootstrap github \                                                                                                                                                                     6.94% 10/67GB 
  --token-auth \
  --owner=DylanMunyard \
  --repository=pi-setup-notes \
  --branch=main \
  --path=k3s
```
