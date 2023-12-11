job "miniflux" {
  datacenters = ["*"]
  type = "service"

  group "app" {
    count = 1

    network {
      port "http" {}
    }

    service {
      name     = "${JOB}"
      tags     = ["ingress:enabled"]
      port     = "http"
      provider = "nomad"
    }

    task "miniflux" {
      driver = "exec"

      artifact {
        source = "https://github.com/miniflux/v2/releases/download/2.0.50/miniflux-linux-amd64"
        destination = "local/miniflux"
        mode = "file"
      }

      config {
        command = "miniflux"
        args    = [ "-config-file", "local/miniflux.conf" ]
      }

      template {
        data = <<EOF
{{ with nomadVar "nomad/jobs/miniflux" -}}
DATABASE_URL=host={{ range nomadService "postgres" }}{{ .Address }}{{ end}} user={{ .username }} password={{ .password }} dbname={{ .database}} sslmode=disable
{{ end -}}
BASE_URL=http://{{ env "NOMAD_IP_http" }}/miniflux
RUN_MIGRATIONS=1
LISTEN_ADDR={{ env "NOMAD_IP_http" }}:{{ env "NOMAD_PORT_http" }}
        EOF
        destination = "local/miniflux.conf"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }
    }

  }
}