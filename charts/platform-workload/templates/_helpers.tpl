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
{{- define "platform-workload.renderService" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- $service := .service -}}
{{- $workload := index $root.Values.workloads $service.workload -}}
{{- if not $workload }}{{ fail (printf "service %s references missing workload %s" $name $service.workload) }}{{ end }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "platform-workload.fullname" $root }}-{{ $name }}
  namespace: {{ include "platform-workload.namespace" $root }}
  labels:
    {{- include "platform-workload.labels" $root | nindent 4 }}
    app.kubernetes.io/component: {{ $service.workload }}
spec:
  type: {{ $service.type | default "ClusterIP" }}
  selector:
    {{- include "platform-workload.selectorLabels" (dict "root" $root "name" $service.workload) | nindent 4 }}
  ports:
    - name: {{ $service.portName | default "http" }}
      {{- if or (lt (int $service.port) 1) (gt (int $service.port) 65535) }}{{ fail (printf "services.%s.port must be between 1 and 65535" $name) }}{{ end }}
      port: {{ required (printf "services.%s.port is required" $name) $service.port }}
      targetPort: {{ $service.targetPort | default "http" }}
{{- end -}}

{{- define "platform-workload.effectiveWorkload" -}}
{{- $root := .root -}}
{{- $workload := .workload -}}
{{- $profileName := $workload.profile | default "" -}}
{{- $profile := dict -}}
{{- if $profileName -}}
  {{- if not (hasKey $root.Values.profiles $profileName) -}}
    {{- fail (printf "workloads.%s references missing profile %s" .name $profileName) -}}
  {{- end -}}
  {{- $profile = get $root.Values.profiles $profileName -}}
{{- end -}}
{{- $effective := deepCopy $profile -}}
{{- $effective = mergeOverwrite $effective (deepCopy $workload) -}}
{{- toYaml $effective -}}
{{- end -}}

{{- define "platform-workload.hasService" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- if hasKey $root.Values.services $name -}}true
{{- else if $root.Values.servicesFromWorkloads -}}
  {{- $rawWorkload := index $root.Values.workloads $name -}}
  {{- if $rawWorkload -}}
    {{- $effective := include "platform-workload.effectiveWorkload" (dict "root" $root "workload" $rawWorkload "name" $name) | fromYaml -}}
    {{- if and (hasKey $effective "service") (or (not (hasKey $effective.service "enabled")) $effective.service.enabled) }}true{{- else }}false{{- end }}
  {{- else }}false{{- end }}
{{- else }}false{{- end }}
{{- end -}}
