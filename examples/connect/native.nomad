job "connect-native" {
  datacenters = ["dc1"]

  group "generator" {
    network {
      port "api" {}
    }

    service {
      name = "uuid-api"
      port = "${NOMAD_PORT_api}"

      connect {
        native = true
      }
    }

    task "generate" {
      driver = "podman"

      config {
        image        = "docker.io/hashicorpnomad/uuid-api:v3"
        network_mode = "host"
      }

      env {
        BIND = "0.0.0.0"
        PORT = "${NOMAD_PORT_api}"
      }
    }
  }

  group "frontend" {
    network {
      port "http" {
        static = 9800
      }
    }

    service {
      name = "uuid-fe"
      port = "9800"

      connect {
        native = true
      }
    }

    task "frontend" {
      driver = "podman"

      config {
        image        = "docker.io/hashicorpnomad/uuid-fe:v3"
        network_mode = "host"
      }

      env {
        UPSTREAM = "uuid-api"
        BIND     = "0.0.0.0"
        PORT     = "9800"
      }
    }
  }
}
