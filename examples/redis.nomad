job "redis" {
  datacenters = ["dc1"]
  type        = "service"

  group "cache" {
    network {
      port "redis" { to = 6379 }
    }

    ephemeral_disk {
      size = 101
    }

    task "redis" {
      driver = "podman"

      config {
        image = "docker://redis"
        ports = ["redis"]
        network_mode = "host"
      }
    }
  }
}
