job "postgres" {
  datacenters = ["*"]
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }

  group "app" {
    count = 1

    network {
      port "api" {
        static = 5432
      }
    }

    service {
      name     = "postgres"
      tags     = ["database", "database:postgres"]
      port     = "api"
      provider = "nomad"
    }

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    vault {
      policies = ["kv"]
      env = false
      change_mode = "noop"
    }

    volume "data" {
      type      = "host"
      read_only = false
      source    = "host"
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "postgres:15.4-alpine"
        ports = [ "api" ]
      }

      volume_mount {
        volume      = "data"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      template {
        destination = "secrets/vault.env"
        env = true
        data = <<EOT
        {{ with secret "kv/apps/postgres/super" -}}
          POSTGRES_USER="{{ .Data.data.username }}"
          POSTGRES_PASSWORD="{{ .Data.data.password }}"
        {{ end -}}
        EOT
      }

      resources {
        memory = 100 # mb
      }
    }
  }
}
