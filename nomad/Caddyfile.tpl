localhost {

  handle {
    respond "Oletko eksynyt?"
  }

  {{- range nomadServices }}
  {{- range nomadService .Name }}
  {{- if .Tags | contains "ingress:enabled" }}
  handle /{{ .Name | toLower }}* {
    reverse_proxy {{ .Address }}:{{ .Port}}
  }
  {{- end }}
  {{- end }}
  {{- end }}
}
