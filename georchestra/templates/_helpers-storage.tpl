{{/*
georchestra.storage.claimName

Returns the PersistentVolumeClaim name for a given storage key.

If `georchestra.storage.<key>.existingClaim` is set, it is returned as-is (it must
already be a valid Kubernetes PVC name).

Otherwise, returns the chart-managed PVC name using a DNS-1123 compatible form
of the storage key (underscores are replaced with dashes):
  <release-fullname>-<storage-key-with-dashes>
*/}}
{{- define "georchestra.storage.claimName" -}}
{{- $root := index . 0 -}}
{{- $key  := index . 1 -}}
{{- $s := get $root.Values.georchestra.storage $key | default dict -}}
{{- $defaultName := printf "%s-%s" (include "georchestra.fullname" $root) (replace "_" "-" $key) -}}
{{- default $defaultName $s.existingClaim -}}
{{- end -}}
