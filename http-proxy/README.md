# http-proxy

Helm chart for geOrchestra http-proxy: https://github.com/georchestra/http-proxy

Runs the proxy as a standalone fat JAR (embedded Jetty) using the
`georchestra/http-proxy:latest` Docker image introduced in
https://github.com/georchestra/http-proxy/pull/1.

## Configuration

The proxy reads its configuration from a properties file whose path is
defined by the `PROXY_PROP_PATH` environment variable. The chart renders
`values.configMap.proxyProperties` into a `ConfigMap` and mounts it at
`/config/proxy.properties`.

`PROXY_PROP_PATH` defaults to `/proxy.properties,/config/proxy.properties`:
the defaults bundled in the image (e.g. `requestHeaderWhitelist`) are loaded
first, then the mounted file overrides them key by key. To forward all request
headers again, set `requestHeaderWhitelist =` (empty value) in your
`proxyProperties`; commenting it out keeps the bundled default.

## Network policies

Set `networkPolicy.enabled=true` to apply the bundled `NetworkPolicy`.
Override `networkPolicy.ingress` and `networkPolicy.egress` to match the
clients and upstream hosts the proxy must reach in your cluster.
