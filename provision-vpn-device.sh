#!/bin/bash
set -eux

domain=$(hostname --fqdn)

if  [ "$(hostname)" = 'moon' ]; then
local='moon'
local_ts='10.1.0.0/16'
remote='sun'
remote_ts='10.2.0.0/16'
remote_ip='10.2.0.2'
else
local='sun'
local_ts='10.2.0.0/16'
remote='moon'
remote_ts='10.1.0.0/16'
remote_ip='10.1.0.2'
fi

#
# install the strongswan charon daemon (has native systemd integration).
# NB do not install the strongswan package as it will use the legacy stuff (e.g. ipsec.conf).

apt-get install -y charon-systemd
systemctl status strongswan-swanctl
swanctl --version


#
# configure.

cp /vagrant/shared/example-ca/example-ca-crt.pem /etc/swanctl/x509ca
cp /vagrant/shared/example-ca/$local.vpn.example.com-crt.pem /etc/swanctl/x509
cp /vagrant/shared/example-ca/$local.vpn.example.com-key.pem /etc/swanctl/private
mv /etc/swanctl/swanctl.conf ~/swanctl.conf.orig
# see https://wiki.strongswan.org/projects/strongswan/wiki/StrongswanConf
cat >/etc/swanctl/swanctl.conf <<EOF
connections {
    net-net {
        local {
            auth = pubkey
            certs = $local.vpn.example.com-crt.pem
        }
        remote {
            auth = pubkey
            id = "CN=$remote.vpn.example.com"
        }
        remote_addrs = $remote.vpn.example.com
        children {
            net-net {
                local_ts = $local_ts
                remote_ts = $remote_ts
                dpd_action = restart
                start_action = trap
            }
        }
    }
}
EOF
swanctl --load-all


#
# kick the tires.

ping -n -c 4 $remote_ip || true
swanctl --list-conns
swanctl --list-sas
swanctl --stats
ip xfrm state
ip xfrm policy


#
# add useful commands to the shell history.

cat >>~/.bash_history <<EOF
ping -n $remote_ip
swanctl --list-conns
swanctl --list-sas
swanctl --stats
ip xfrm state
ip xfrm policy
systemctl status strongswan-swanctl
systemctl restart strongswan-swanctl
journalctl -u charon-systemd
journalctl -u strongswan-swanctl
EOF
