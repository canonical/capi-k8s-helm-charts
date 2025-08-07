{{/*
Set clusterName to user provided value, defaults to release name 
*/}}
{{- define "openstack-ck8s-cluster.clusterName" -}}
{{- default .Release.Name .Values.clusterName | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a name for a cluster component.
*/}}
{{- define "openstack-ck8s-cluster.componentName" -}}
{{- $ctx := index . 0 -}}
{{- $componentName := index . 1 -}}
{{- printf "%s-%s" $ctx.Release.Name $componentName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "openstack-ck8s-cluster.chart" -}}
{{-
  printf "%s-%s" .Chart.Name .Chart.Version |
    replace "+" "_" |
    trunc 63 |
    trimSuffix "-" |
    trimSuffix "." |
    trimSuffix "_"
}}  
{{- end }}

{{/*
Common labels
*/}}
{{- define "openstack-ck8s-cluster.commonLabels" -}}
helm.sh/chart: {{ include "openstack-ck8s-cluster.chart" . }}
{{ .Values.projectPrefix }}/managed-by: {{ .Release.Service }}
{{ .Values.projectPrefix }}/infrastructure-provider: openstack
{{- end -}}

{{/*
Selector labels for cluster-level resources
*/}}
{{- define "openstack-ck8s-cluster.selectorLabels" -}}
{{ .Values.projectPrefix }}/cluster: {{ include "openstack-ck8s-cluster.clusterName" . }}
{{- end -}}

{{/*
Labels for cluster-level resources
*/}}
{{- define "openstack-ck8s-cluster.labels" -}}
{{ include "openstack-ck8s-cluster.commonLabels" . }}
{{ include "openstack-ck8s-cluster.selectorLabels" . }}
{{- end -}}

{{/*
Selector labels for component-level resources
*/}}
{{- define "openstack-ck8s-cluster.componentSelectorLabels" -}}
{{- $ctx := index . 0 -}}
{{- $componentName := index . 1 -}}
{{ include "openstack-ck8s-cluster.selectorLabels" $ctx }}
{{ $ctx.Values.projectPrefix }}/component: {{ $componentName }}
{{- end -}}

{{/*
Labels for component-level resources
*/}}
{{- define "openstack-ck8s-cluster.componentLabels" -}}
{{ include "openstack-ck8s-cluster.commonLabels" (index . 0) }}
{{ include "openstack-ck8s-cluster.componentSelectorLabels" . }}
{{- end -}}

{{/*
Name of the secret containing the cloud credentials.
*/}}
{{- define "openstack-ck8s-cluster.cloudCredentialsSecretName" -}}
{{- if .Values.cloudCredentialsSecretName -}}
{{- .Values.cloudCredentialsSecretName -}}
{{- else -}}
{{ include "openstack-ck8s-cluster.componentName" (list . "cloud-credentials") -}}
{{- end -}}
{{- end -}}

{{/*
Cloud credential content
*/}}
{{- define "openstack-ck8s-cluster.cloudCredentialContent" -}}
{{- $clouds := dict }}
{{- if .Values.cloudCredentialsSecretName -}}
  {{- $secret := lookup "v1" "Secret" .Release.Namespace .Values.cloudCredentialsSecretName  -}}
  {{- if $secret }}
    {{- $clouds := fromYaml (index $secret.data "clouds.yaml" | default "" | b64dec) -}}
  {{- else }}
    {{- fail (printf "cloud credential secret not found") }}
  {{- end }}
{{- else }}
  {{- $clouds := .Values.clouds }}
{{- end }}
{{ index $clouds .Values.cloudName | default dict | toYaml | trim }}
{{- end -}}
