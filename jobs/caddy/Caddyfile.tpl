{{ with nomadVar "kv/cluster_info" }}{{ .external_addr }}{{ end }} {

  {{- range nomadServices }}
  {{- range nomadService .Name }}
  {{- if .Tags | contains "ingress:enabled" }}
  handle /{{ .Name | toLower }}* {
    reverse_proxy {{ .Address }}:{{ .Port}}
  }
  {{- end }}
  {{- end }}
  {{- end }}

  handle {
    respond "Oletko eksynyt?"
  }
}
