KUBE_BURNER_VERSION=1.1.0
KUBE_DIR=${KUBE_DIR:-/tmp}
KUBE_BURNER_URL="https://github.com/kube-burner/kube-burner-ocp/releases/download/v${KUBE_BURNER_VERSION}/kube-burner-ocp-V${KUBE_BURNER_VERSION}-linux-x86_64.tar.gz"
PROMETHEUS_HOST=https://$(oc get route -n openshift-monitoring prometheus-k8s -o go-template="{{.spec.host}}")
PROMETHEUS_ISTIO_HOST=https://$(oc get route -n istio-system prometheus -o go-template="{{.spec.host}}")
PROMETHEUS_PASSWORD=$(oc get secret/htpasswd -n istio-system -o go-template="{{.data.rawPassword|base64decode}}")
TOKEN=$(oc sa new-token -n openshift-monitoring prometheus-k8s)
WORKLOAD=${WORKLOAD:?}
EXTRA_FLAGS=${EXTRA_FLAGS:-}
PODS_PER_NODE=${PODS_PER_NODE:-220}

export PROMETHEUS_HOST PROMETHEUS_ISTIO_HOST PROMETHEUS_PASSWORD TOKEN

cd ${WORKLOAD}

if [[ ! -f /tmp/kube-burner-ocp ]]; then
   curl --fail --retry 8 --retry-all-errors -sS -L "${KUBE_BURNER_URL}" | tar -xzC "${KUBE_DIR}/" kube-burner-ocp
fi


cmd="/tmp/kube-burner-ocp ${WORKLOAD} ${EXTRA_FLAGS}"
# If ES_SERVER is specified
if [[ -n ${ES_SERVER} ]]; then
  cmd+=" --es-server=${ES_SERVER} --es-index=${ES_INDEX}"
fi

if [[ ${WORKLOAD} =~ cluster-density-sm|envoy-scale ]]; then
  WORKLOAD="cluster-density-v2"
elif [[ ${WORKLOAD} == "node-density-sm" ]]; then
  WORKLOAD="node-density"
fi

echo ${cmd}
${cmd}
exit $?
