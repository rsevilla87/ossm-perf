# East/west networking

[K8s-netperf](https://github.com/cloud-bulldozer/k8s-netperf) is the tool we use to orchestrate the east-west network load tests. Its execution is orchestrated by the e2e-benchmarking wrapper, network-perf-v2 using the configuration described in sm-run.yaml that orchestrates a netperf based workload in different scenarios and configurations.

Scenarios:

The test scenarios are very similar to the ones executed in regular OpenShift (baseline) using the default CNI plugin OVNKubernetes. The intention of this is to evaluate the impact of OpenShift Service Mesh by doing a baseline comparison.

Pod 2 service:

- TCP_STREAM/UDP_STREAM: The stream scenarios are meant to benchmark TCP/UDP network throughput using different packet sizes
  - Message sizes: 64, 4096 and 8192
  - Streams: 1 and 2
- TCP_RR. Request/response test meant to benchmark TCP network latency
  - Message sizes: 1024

Run the test with:

```shell
$ SIDECAR=true ./run.sh sm-mtls.yml
namespace/netperf created
Adding istio-injection=enabled label to ns
namespace/netperf labeled
serviceaccount/netperf created
clusterrole.rbac.authorization.k8s.io/system:openshift:scc:hostnetwork added: "netperf"
./k8s-netperf --all --config sm-mtls.yml --clean=false --csv=false
INFO[2024-04-25 11:15:30] Starting k8s-netperf (0.1.22@a61bca0c837ed08bdac7f66f275e40de8d1f8c3b)
INFO[2024-04-25 11:15:30] 📒 Reading sm-mtls.yml file.
INFO[2024-04-25 11:15:30] 📒 Reading sm-mtls.yml file - using ConfigV2 Method.
INFO[2024-04-25 11:15:30] 🔬 prometheus discovered at openshift-monitoring
INFO[2024-04-25 11:15:30] ♻️  Namespace already exists, reusing it
INFO[2024-04-25 11:15:30] ♻️  Service account already exists, reusing it
etc
```

## Considerations

pod 2 pod fails with mTLS: https://github.com/istio/istio/issues/37431

