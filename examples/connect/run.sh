#!/bin/bash
# example based on https://www.hashicorp.com/blog/consul-connect-native-tasks-in-hashicorp-nomad-0-12
MYDIR="$(dirname "$(readlink -f "$0")")"
consul config write "$MYDIR/intention-config.hcl"
nomad job run "$MYDIR/native.nomad"
