#!/bin/bash
set -e
set -u

CONSUL_KEY="$(cat /shared/consul.key)"
echo '# placeholder' >/etc/consul.d/consul.hcl

touch /etc/consul.d/consul.env

if test -f /etc/consul.d/consul.json ; then
    exit 0
elif hostname -a | grep -q server; then
    NOMAD_SERVER_KEY="$(cat /shared/nomad.key)"
    cat >/etc/consul.d/consul.json <<EOF
{
  "data_dir": "/opt/consul",
  "server": true,
  "bootstrap": true,
  "encrypt": "$CONSUL_KEY",
  "encrypt_verify_incoming": true,
  "encrypt_verify_outgoing": true
}
EOF
    cat >/etc/nomad.d/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"

server {
  enabled          = true
  bootstrap_expect = 1
  encrypt = "$NOMAD_SERVER_KEY"
}
datacenter = "dc1"

consul {
  address = "127.0.0.1:8500"
}
EOF
else
    cat >/etc/consul.d/consul.json <<EOF
{
  "data_dir": "/opt/consul",
  "server": false,
  "retry_join": ["server:8301"],
  "encrypt": "$CONSUL_KEY",
  "encrypt_verify_incoming": true,
  "encrypt_verify_outgoing": true
}
EOF

    cat >/etc/nomad.d/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"

server {
  enabled = false
}
datacenter = "dc1"

client {
  enabled = true
}

plugin {
  config {
    enabled = true
  }
}
EOF
fi

chown consul:consul -R /etc/consul.d
chmod 640 /etc/consul.d/*
chown podman:podman -R /etc/nomad.d
chmod 640 /etc/nomad.d/*
