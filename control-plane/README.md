# Control-plane scale tests

## Service Mesh density

It contains two jobs. First one, `gateway-route` creates a route in the `istio-system` namespace that will be used by the readiness probes of the client pods

Second job, `sm-density`, creates the following objects per namespace:

- 3 deployments with 2 replicas using: `quay.io/cloud-bulldozer/nginx:latest`
- 3 deployments with 2 replicas using: `quay.io/cloud-bulldozer/curl:latest`. The pods in this deployment have configued a `readinessProbe` that cURLs one of the services and the route pointing to the ingress gateway.
- 1 gateway
- 3 services backed by the nginx pods
- 3 virtualservices pointing to the previous services
- 4 secrets mounted by all pods
- 4 configmaps mounted by all pods

### KPIs

- Pass/Fail of the test
- Service Mesh resource usage
  - `istiod` CPU & memory usage
  - `Prometheus` CPU & memory usage
- `kube-apiserver`: Istio generates considerable amount of extra load on this component (extra watchers and API requests)
  - CPU & memory usage
  - API latency
- P99 `PodReadyLatency`. Useful to measure how long it take all the network plumbing of a pod.