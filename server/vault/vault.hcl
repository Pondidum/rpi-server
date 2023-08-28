ui        = true
api_addr  = "http://127.0.0.1:8200"

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = true
}
