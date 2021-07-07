job "sleep" {
  datacenters = ["dc1"]
  type        = "service"

  group "sameclient" {
    ephemeral_disk {
      size = 101
    }

    task "sleep" {
      driver = "podman"

      config {
        image = "docker://alpine"
        network_mode = "host"

        args = [
          "sleep",
          "infinity",
        ]
      }
    }
    scaling {
      enabled = true
      min = 3
      max = 10
      policy {
      }
    }
  }
}
