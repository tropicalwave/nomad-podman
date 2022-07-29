#!/bin/bash
set -e
set -u

if test -f /etc/nomad.d/bootstrapped || hostname -a | grep -q client; then
    exit 0
fi

while true; do
    curl http://localhost:4646 >&/dev/null && break
    sleep 0.5
done

SECRETS="$(nomad acl bootstrap)"
NOMAD_TOKEN="$(awk -F= '/Secret ID/ { print $2 }' <<<"$SECRETS" | tr -d " ")"
export NOMAD_TOKEN

nomad acl policy apply \
  -description "Allow everything" \
  anonymous \
  /etc/initial-acls/nomad/allow-all.hcl

echo "$NOMAD_TOKEN" >/etc/nomad.d/bootstrapped
