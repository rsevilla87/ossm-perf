# Control-plane scale tests

## Global environment variables

These benchmarks are executed with the help of the [kube-burner](https://github.com/kube-burner/kube-burner) plugin, [kube-burner-ocp](https://github.com/kube-burner/kube-burner-ocp). Cluster authentication is configured by `KUBECONFIG`, by default `kube-burner` looks for it in `${HOME}/.kube/config`
Indexing is enabled by default thanks to the variables `ES_SERVER` and `ES_INDEX` and append extra flags to `kube-burner-ocp` with `EXTRA_FLAGS`

## Cluster-density Service Mesh

It contains two jobs. First one, `create-namespaces` creates the required namespaces (9 namespaces per worker node) of the benchmark.

Second job, `cluster-density-sm`, creates the following objects per namespace:

- 2 deployments with 2 pod replicas using: `quay.io/cloud-bulldozer/nginx:latest` (Server).
- 2 deployments with 2 pod replicas using: `quay.io/cloud-bulldozer/hloader:latest` (Client). The pods in this deployment have configured:
  - A `readinessProbe` that cURLs one of the services and the route pointing to the ingress gateway.
  - A command that runs a constant load generation script that performs 50 HTTP rps against one of the services
- 1 gateway
- 2 services backed by the nginx pods
- 1 virtualservices pointing to the previous services
- 2 configmap mounted by the clients that contains the load generation script
- 1 route pointing to the ingress gateway in istio-system. These routes are actually created in the istio-system namespace and are configured with the the gateway hostname.

To enable sidecar injection, projects/namespaces created by this workload are labeled with `istio-injection: enabled`, and the pods created in these namespaces are annotated with `sidecar.istio.io/inject: "true"`.

Run it with:

```shell
WORKLOAD=cluster-density-sm ./run.sh
```

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

By default it creates 220 pods per node, this value can be tuned through the env var `PODS_PER_NODE`.

Run it with:

```shell
WORKLOAD=node-density-sm ./run.sh
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
WORKLOAD=envoy-scale ./run.sh
```

### KPIs

- Pass/Fail of the test
- `Istio-proxy` CPU usage / 1k requests
- `Istio-proxy` memory usage
- Istio control plane
