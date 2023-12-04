# East/west networking

[K8s-netperf](https://github.com/cloud-bulldozer/k8s-netperf) is the tool we use to orchestrate the east-west network load tests. Its execution is orchestrated by the e2e-benchmarking wrapper, network-perf-v2 using the configuration described in sm-run.yaml that orchestrates a netperf based workload in different scenarios and configurations.

Scenarios:

The test scenarios are very similar to the ones executed in regular OpenShift (baseline) using the default CNI plugin OVNKubernetes. The intention of this is to evaluate the impact of OpenShift Service Mesh by doing a baseline comparison.

Pod 2 pod and pod 2 service:

- TCP_STREAM/UDP_STREAM: The stream scenarios are meant to benchmark TCP/UDP network throughput using different packet sizes
  - Message sizes: 64, 1024, 4096 and 8192
- TCP_RR. Request/response test meant to benchmark TCP network latency
  - Message sizes: 1024
- mtLS true/false

Node 2 node:

- TCP_STREAM/UDP_STREAM: The stream scenarios are meant to benchmark TCP/UDP network throughput using different packet sizes
  - Message sizes: 64, 1024, 4096 and 8192
- TCP_RR. Request/response test meant to benchmark TCP network latency
  - Message sizes: 1024

KPIs:
- TCP/UDP throughput with different packet sizes
- TCP latency with different packet sizes


## Considerations

node 2 node tests don't use the overlay network, traffic travels directly from the worker NICs

pod 2 pod fails with mTLS: https://github.com/istio/istio/issues/37431


# Ingress

WIP
