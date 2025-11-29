{{- define "external-secret-manager.base" -}}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ .item.name }}
  namespace: "{{ .item.namespace | default .Release.Namespace | default "default" }}"
spec:
  refreshInterval: "{{ .refreshInterval | default .Values.globals.refreshInterval }}"
  secretStoreRef:
    name: "{{ .secretStoreRefName | default .Values.globals.secretStoreRefName }}"
    kind: "{{ .secretStoreRefKind | default .Values.globals.secretStoreRefKind }}"
  target:
    name: "{{ .item.targetName | default .item.name }}"
    creationPolicy: Owner
{{- end -}}

{{- define "external-secret-manager.overide.simple" -}}
spec:
  data:
    - secretKey: "{{ .item.dataSecretKey }}"
      remoteRef:
        key: "{{ .item.remoteRefKey }}"
{{- end -}}

{{- define "external-secret-manager.overide.subpath" -}}
spec:
  dataFrom:
    - find:
        path: "{{ .item.remoteRefKey }}"
        name:
          regexp: ".*"
      rewrite:
        - regexp:
            source: "{{ .item.remoteRefKey }}/(.*)"
            target: "$1"
        - regexp:
            source: "[^a-zA-Z0-9 -]"
            target: "_"
{{- end -}}

{{- define "external-secret-manager.simple" -}}
{{- $Values := .Values }}
{{- $Release := .Release }}
{{- range $index, $item := $Values.SimpleSecrets -}}
{{- $context := dict "item" $item "Values" $Values "Release" $Release -}}
{{- with $context }}
---
{{ include "common.utils.merge" (list . "external-secret-manager.overide.simple" "external-secret-manager.base") }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "external-secret-manager.subpath" -}}
{{- $Values := .Values }}
{{- $Release := .Release }}
{{- range $index, $item := $Values.SubPathSecrets -}}
{{- $context := dict "item" $item "Values" $Values "Release" $Release -}}
{{- with $context }}
---
{{ include "common.utils.merge" (list . "external-secret-manager.overide.subpath" "external-secret-manager.base") }}
{{- end -}}
{{- end -}}
{{- end -}}