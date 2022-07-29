#!/bin/bash
set -e
set -u

if test -f /etc/consul.d/bootstrapped ; then
    exit 0
elif hostname -a | grep -q client; then
    cat >>~/.bashrc <<EOF

CONSUL_HTTP_TOKEN="$(cat /shared/consul-agents.token)"
export CONSUL_HTTP_TOKEN
EOF

    touch /etc/consul.d/bootstrapped
    exit 0
fi

CONSUL_HTTP_TOKEN="$(cat /shared/consul-agents.token)"
export CONSUL_HTTP_TOKEN

while true; do
    consul operator raft list-peers | grep -q leader && break
    sleep 0.5
done

consul acl policy create \
  -name "nomad-server" \
  -description "Nomad Server Policy" \
  -rules @/etc/initial-acls/consul/nomad-server-policy.hcl >/dev/null

consul acl policy create \
  -name "nomad-client" \
  -description "Nomad Client Policy" \
  -rules @/etc/initial-acls/consul/nomad-client-policy.hcl >/dev/null

consul acl policy create \
  -name "dns-requests" \
  -rules @/etc/initial-acls/consul/dns-request-policy.hcl >/dev/null

consul acl token create \
  -description "Nomad Server Token" \
  -policy-name "nomad-server" \
  -secret="$(cat /shared/nomad-server.token)" >/dev/null

# Should be replaced by individual tokens per node in production
consul acl token create \
  -description "Nomad Client Token" \
  -policy-name "nomad-client" \
  -secret="$(cat /shared/nomad-client.token)" >/dev/null

consul acl token create \
  -description "Token for DNS Requests" \
  -policy-name dns-requests \
  -secret="$(cat /shared/dns-requests.token)" >/dev/null

cat >>~/.bashrc <<EOF

CONSUL_HTTP_TOKEN="$(cat /shared/consul-agents.token)"
export CONSUL_HTTP_TOKEN
EOF

touch /etc/consul.d/bootstrapped
