data_dir = "/opt/nomad/data"

server {
  enabled = false
}
datacenter = "dc1"

client {
  enabled = true
}

consul {
  address = "127.0.0.1:18500"
}

plugin {
  config {
    enabled = true
  }
}

ports {
  http = 14646
}
