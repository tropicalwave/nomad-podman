#!/bin/bash
set -e
set -u

if test -d shared/; then
    echo 'Initialization already done. Skipping...'
    exit 0
fi

mkdir shared/
openssl rand -base64 32 >shared/consul.key
openssl rand -base64 32 >shared/nomad.key
