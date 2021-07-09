#!/bin/bash
set -e
set -u

CONSUL_KEY="$(cat /shared/consul.key)"
echo '# placeholder' >/etc/consul.d/consul.hcl

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
    NUMBER="$(hostname -a | awk -F_ '{ print $NF }')"

    cat >/etc/consul.d/consul.json <<EOF
{
  "data_dir": "/opt/consul",
  "server": false,
  "retry_join": ["server:8301"],
  "ports": {
    "serf_lan": $((8301+NUMBER*2)),
    "dns": $((8600+NUMBER)),
    "http": $((8500+NUMBER))
  },
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

consul {
  address = "127.0.0.1:$((8500+NUMBER))"
}

plugin {
  config {
    enabled = true
  }
}

ports {
  http = $((4646+NUMBER*3))
}
EOF
fi

chown consul:consul -R /etc/consul.d
chmod 640 /etc/consul.d/*
chown podman:podman -R /etc/nomad.d
chmod 640 /etc/nomad.d/*
