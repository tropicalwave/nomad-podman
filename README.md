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
podman exec -ti podman-nomad_client_1 /bin/bash
# nomad job run /examples/redis.nomad
```

Nomad can also be reached by browsing to <http://localhost:4646>

## Overview

![Architecture](/images/architecture.svg)
