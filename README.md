# nomad-podman-example

[![GitHub Super-Linter](https://github.com/tropicalwave/nomad-podman/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

## Introduction

This is a test project to get used to nomad and consul
with a podman driver. After successful startup, one nomad
server and three nomad clients will be up and running.

## Quickstart

```bash
./prepare.sh
podman-compose up -d
```

Nomad can then be reached by browsing to <http://localhost:4646>

## Architecture

![Architecture](/images/architecture.svg)

## Starting jobs

### Redis

```bash
podman exec -ti podman-nomad_client_1 /bin/bash
# nomad job run /examples/redis.nomad
```

### Traefik with web app

Example taken from <https://learn.hashicorp.com/tutorials/nomad/load-balancing-traefik>

```bash
podman exec -ti podman-nomad_client_1 /bin/bash
# nomad job run /examples/traefik.nomad
# nomad job run /examples/demo-webapp.nomad

# ALLOC="$(nomad job allocs -json traefik | jq -r .[].ID)"
# IP="$(nomad alloc status -json "$ALLOC" | jq -r .AllocatedResources.Shared.Networks[].IP)"
# curl "http://$IP:8080/myapp"

```
