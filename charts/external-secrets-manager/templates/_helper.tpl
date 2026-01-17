{{- define "external-secret-manager.base" -}}
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

{{- define "external-secret-manager.overide.dotenv" -}}
{{- $rawKey := "__dotenv" -}}
spec:
  data:
    - secretKey: "{{ $rawKey }}"
      remoteRef:
        key: "{{ .item.remoteRefKey }}"
        {{- with .item.remoteRefProperty }}
        property: "{{ . }}"
        {{- end }}
        {{- with .item.remoteRefVersion }}
        version: "{{ . }}"
        {{- end }}
        {{- with .item.remoteRefDecodingStrategy }}
        decodingStrategy: "{{ . }}"
        {{- end }}
        {{- with .item.remoteRefConversionStrategy }}
        conversionStrategy: "{{ . }}"
        {{- end }}
        {{- with .item.remoteRefMetadataPolicy }}
        metadataPolicy: "{{ . }}"
        {{- end }}
  target:
    template:
      engineVersion: v2
      mergePolicy: Replace
      templateFrom:
        - literal: |
{{ include "external-secret-manager.dotenv.literal" . | indent 12 }}
          target: Data
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

{{- define "external-secret-manager.dotenv" -}}
{{- $Values := .Values }}
{{- $Release := .Release }}
{{- range $index, $item := $Values.DotEnvSecrets -}}
{{- $context := dict "item" $item "Values" $Values "Release" $Release -}}
{{- with $context }}
---
{{ include "common.utils.merge" (list . "external-secret-manager.overide.dotenv" "external-secret-manager.base") }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "external-secret-manager.dotenv.literal" -}}
{{- $rawKey := "__dotenv" -}}
{{ printf "{{- $raw := get .Data %q | default \"\" -}}\n" $rawKey }}
{{ printf "{{- $lines := regexSplit \"\\r?\\n\" $raw -1 -}}\n" }}
{{ printf "{{- range $line := $lines -}}\n" }}
{{ printf "{{- $trim := trim $line -}}\n" }}
{{ printf "{{- if and $trim (not (hasPrefix $trim \"#\")) -}}\n" }}
{{ printf "{{- $parts := splitn 2 \"=\" $trim -}}\n" }}
{{ printf "{{- if eq (len $parts) 2 -}}\n" }}
{{ printf "{{- $key := trim (index $parts 0) -}}\n" }}
{{ printf "{{- $val := trim (index $parts 1) -}}\n" }}
{{ printf "{{- if $key -}}\n" }}
{{ printf "{{ $key }}: {{ $val | quote }}\n" }}
{{ printf "{{- end -}}\n" }}
{{ printf "{{- end -}}\n" }}
{{ printf "{{- end -}}\n" }}
{{ printf "{{- end -}}\n" }}
{{- end -}}
