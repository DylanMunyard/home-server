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
