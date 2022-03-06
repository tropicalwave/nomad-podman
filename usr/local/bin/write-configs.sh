#!/bin/bash
set -e
set -u

CONSUL_KEY="$(cat /shared/consul.key)"
echo '# placeholder' >/etc/consul.d/consul.hcl

touch /etc/consul.d/consul.env

if test -f /etc/consul.d/consul.json ; then
    exit 0
elif hostname -a | grep -q server; then
    # Server configuration
    NOMAD_SERVER_KEY="$(cat /shared/nomad.key)"
    cat >/etc/consul.d/consul.json <<EOF
{
  "data_dir": "/opt/consul",
  "server": true,
  "bootstrap": true,
  "encrypt": "$CONSUL_KEY",
  "encrypt_verify_incoming": true,
  "encrypt_verify_outgoing": true,
  "acl": {
    "tokens": {
      "initial_management": "$(cat /shared/consul-agents.token)",
      "default": "$(cat /shared/consul-agents.token)"
    }
  },
  "connect": {
    "enabled": true
  },
  "client_addr": "0.0.0.0",
  "ui_config": {
    "enabled": true
  }
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
  allow_unauthenticated = false
  token = "$(cat /shared/nomad-server.token)"
}
EOF

    cat >/etc/haproxy/haproxy.cfg <<EOF
frontend http_front
    bind *:8080
    default_backend http_back
    timeout connect 5000
    timeout client 5000
    timeout server 5000

backend http_back
    balance first
    server-template traefik 1-10 _traefik._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

frontend api_front
    bind *:8081
    default_backend api_back
    timeout connect 5000
    timeout client 5000
    timeout server 5000

backend api_back
    balance first
    server-template traefik-api 1-10 _traefik-api._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

resolvers consul
     nameserver consul 127.0.0.1:8600
     accepted_payload_size 8192
     hold valid 5s
EOF
else
    # Client configuration
    cat >/etc/consul.d/consul.json <<EOF
{
  "data_dir": "/opt/consul",
  "server": false,
  "retry_join": ["server:8301"],
  "encrypt": "$CONSUL_KEY",
  "encrypt_verify_incoming": true,
  "encrypt_verify_outgoing": true,
  "acl": {
    "tokens": {
      "default": "$(cat /shared/consul-agents.token)"
    }
  }
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

consul {
  allow_unauthenticated = false
  token = "$(cat /shared/nomad-client.token)"
}
EOF
fi

cat >/etc/consul.d/acl.hcl <<EOF
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
EOF

chown consul:consul -R /etc/consul.d
chmod 640 /etc/consul.d/*
chown podman:podman -R /etc/nomad.d
chmod 640 /etc/nomad.d/*
