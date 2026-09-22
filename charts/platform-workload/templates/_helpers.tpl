{{- define "platform-workload.name" -}}{{ default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}{{- end -}}
{{- define "platform-workload.fullname" -}}{{- if .Values.fullnameOverride }}{{ .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}{{- else }}{{ printf "%s-%s" .Release.Name (include "platform-workload.name" .) | trunc 63 | trimSuffix "-" }}{{- end }}{{- end -}}
{{- define "platform-workload.namespace" -}}{{ default .Release.Namespace .Values.namespace }}{{- end -}}
{{- define "platform-workload.labels" -}}
app.kubernetes.io/name: {{ include "platform-workload.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}
{{- define "platform-workload.workloadLabels" -}}
{{ include "platform-workload.labels" .root }}
app.kubernetes.io/component: {{ .name }}
{{- end -}}
{{- define "platform-workload.selectorLabels" -}}
app.kubernetes.io/name: {{ include "platform-workload.name" .root }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
app.kubernetes.io/component: {{ .name }}
{{- end -}}
{{- define "platform-workload.image" -}}
{{- $image := .image -}}{{- $repository := required "image.repository is required" $image.repository -}}
{{- if and $image.digest (not (regexMatch "^sha256:[a-f0-9]{64}$" $image.digest)) }}{{ fail "image.digest must match sha256:<64 lowercase hexadecimal characters>" }}{{ end -}}
{{- if $image.digest -}}{{ printf "%s%s@%s" $repository (ternary (printf ":%s" $image.tag) "" (not (empty $image.tag))) $image.digest -}}
{{- else if $image.tag -}}{{ printf "%s:%s" $repository $image.tag -}}{{- else -}}{{ fail "image requires tag or digest" }}{{- end -}}
{{- end -}}
