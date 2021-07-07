data_dir = "/opt/nomad/data"

server {
  enabled          = true
  bootstrap_expect = 1
}
datacenter = "dc1"

consul {
  address = "127.0.0.1:8500"
}
