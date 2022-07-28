# see https://www.consul.io/docs/discovery/dns

node_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "read"
}
