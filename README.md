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

### Traefik with web app

Example taken from <https://learn.hashicorp.com/tutorials/nomad/load-balancing-traefik>

Note: In this example, a webapp running on an arbitrary number of nodes
is exposed to Traefik instances running on _all_ nomad client nodes. In a
real-world scenario, an external load balancer would then forward network
traffic to Traefik. However, since we are only using containers, an
HAProxy process running on the nomad server plays the role of such an
external load balancer. Therefore, one can reach two endpoints on the
host machine after executing the below commands:

* <http://localhost:8080/myapp> (demo webapp)
* <http://localhost:8081/> (Traefik dashboard)

```bash
podman exec -ti podman-nomad_client_1 /bin/bash
# nomad job run /examples/traefik.nomad
# nomad job run /examples/demo-webapp.nomad
```

### Service with Consul Connect native integration

Example taken from <https://www.hashicorp.com/blog/consul-connect-native-tasks-in-hashicorp-nomad-0-12>

```bash
podman exec -ti podman-nomad_client_1 /bin/bash
# consul config write /examples/connect/intention-config.hcl
# nomad job run /examples/connect/native.nomad
```
