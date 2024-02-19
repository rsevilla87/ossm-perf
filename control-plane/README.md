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

Density of 220 pods per node,

```shell
./run.sh --pods-per-node=220
```

### KPIs

- Pass/Fail of the test
- P99 `PodReadyLatency`. Useful to measure how long it take all the network plumbing of a pod.
- Service Mesh resource usage
  - `istiod` CPU & memory usage
  - `Prometheus` CPU & memory usage
  - `istio-proxy` CPU & memory usage

## Envoy-scale

Creates a series of namespaces each one with 100 client and 100 server pods serving static content, where the clients perform a constant rate of requests per second over the servers. The client-server communication is backed by a k8s service, a virtualservice and a destination rule using the LEAST_REQUEST balancing strategy.
The benchmark is divided into multiple jobs, starting from the smaller scale and growing exponentially to the biggest, the aim of this is to evaluate how envoy scales with the number of cluster-wide requests per second and pods.

It can be executed with:

```shell
./run.sh
```

### KPIs

- Pass/Fail of the test
- `Istio-proxy` CPU usage / 1k requests
- `Istio-proxy` memory usage
- Istio control plane
