# Control-plane scale tests

## Cluster-density Service Mesh

It contains two jobs. First one, `gateway-route` creates a route in the `istio-system` namespace that will be used by the readiness probes of the client pods

Second job, `cluster-density-sm`, creates the following objects per namespace:

- 2 deployments with 2 replicas using: `quay.io/cloud-bulldozer/nginx:latest` (Server).
- 2 deployments with 2 replicas using: `quay.io/cloud-bulldozer/hloader:latest` (Client). The pods in this deployment have configured:
  - A `readinessProbe` that cURLs one of the services and the route pointing to the ingress gateway.
  - A constant load generation script that performs 50 HTTP rps against one of the services
- 1 gateway
- 2 services backed by the nginx pods
- 2 virtualservices pointing to the previous services
- 1 configmap mounted by the clients that contains the load generation script
- 1 route pointing to the ingress gateway in istio-system. These routes are actually created in the istio-system namespace and use the gateway hostname to forward traffic to the .

To enable sidecar injection, projects/namespaces created by this workload are labeled with `istio-injection: enabled`, and the pods created in these namespaces are annotated with `sidecar.istio.io/inject: "true"`.

### KPIs

- Pass/Fail of the test
- Service Mesh resource usage
  - `istiod` CPU & memory usage
  - `Prometheus` CPU & memory usage
  - `istio-proxy` CPU & memory usage
- `kube-apiserver`: Istio generates considerable amount of extra load on this component (extra watchers and API requests)
  - CPU & memory usage
  - API latency
- P99 `PodReadyLatency`. Useful to measure how long it take all the network plumbing of a pod.

## Node-density Service Mesh

It creates a single namespace `node-density-sm` with a defined number of "naked" pods per worker node. The purpose of using "naked" pods rather than deployments or ReplicaSets is to isolate the workload from KCM or other factors that may introduce some noise in the pod creation latency measurements.

To enable sidecar injection, projects/namespaces created by this workload are labeled with `istio-injection: enabled`, and the pods created in these namespaces are annotated with `sidecar.istio.io/inject: "true"`

Density of 200 pods per node,

We're currently using m5.2xlarge/m6i.2xlarge instances which have 32 GiB of memory, each `node-density-sm` pod has a memory requests of `138Mi`.

### KPIs

- Pass/Fail of the test
- P99 `PodReadyLatency`. Useful to measure how long it take all the network plumbing of a pod.
- Service Mesh resource usage
  - `istiod` CPU & memory usage
  - `Prometheus` CPU & memory usage
  - `istio-proxy` CPU & memory usage
