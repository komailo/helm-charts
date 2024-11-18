{{- define "mychart.letsencrypt-cluster-issuer" -}}
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-{{ .env }}
spec:
  acme:
    email: "{{ .Values.letsEncryptEmail }}"
    server: {{ include "mychart.letsencrypt-server" .}}
    privateKeySecretRef:
      name: letsencrypt-{{ .env }}
    solvers:
      - dns01:
          digitalocean:
            tokenSecretRef:
              name: digital-ocean-token
              key: token
         {{- if .Values.dnsZones }}
        selector:
          dnsZones:
          {{- range .Values.dnsZones }}
            - "{{ . }}"
          {{- end }}
        {{- end }}
{{- end -}}

{{- define "mychart.letsencrypt-server" -}}
{{- if eq .env "prod" -}}
https://acme-v02.api.letsencrypt.org/directory
{{- else -}}
https://acme-staging-v02.api.letsencrypt.org/directory
{{- end -}}
{{- end -}}

{{- define "mychart.letsencrypt-cluster-issuers" -}}
---
{{ include "mychart.letsencrypt-cluster-issuer" (dict "Values" .Values "env" "staging") }}
---
{{ include "mychart.letsencrypt-cluster-issuer" (dict "Values" .Values "env" "prod") }}
{{- end -}}