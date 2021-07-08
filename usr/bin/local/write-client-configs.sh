#!/bin/bash
set -e
set -u

if ! hostname -a | grep -q client; then
    exit 0
elif test -f /etc/consul.d/consul.json ; then
    exit 0
fi

NUMBER="$(hostname -a | awk -F_ '{ print $NF }')"

echo '# placeholder' >/etc/consul.d/consul.hcl
cat >/etc/consul.d/consul.json <<EOF
{
  "data_dir": "/opt/consul",
  "server": false,
  "retry_join": ["server:8301"],
  "ports": {
    "serf_lan": $((8301+NUMBER*2)),
    "dns": $((8600+NUMBER)),
    "http": $((8500+NUMBER))
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
