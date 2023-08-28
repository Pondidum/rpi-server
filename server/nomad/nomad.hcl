data_dir = "/opt/nomad/data"

# bind_addr = "192.168.1.179"

server {
  enabled = true
  bootstrap_expect = 1
}

client {
  enabled = true

  host_volume "host" {
    path = "/opt/nomad/volumes/host"
    read_only = false
  }
}

vault {
  enabled = true
  address = "http://localhost:8200"
  create_from_role = "nomad"
}