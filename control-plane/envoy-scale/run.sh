KUBE_BURNER_VERSION=1.0.0
PROMETHEUS_HOST=https://$(oc get route -n openshift-monitoring prometheus-k8s -o go-template="{{.spec.host}}")
PROMETHEUS_ISTIO_HOST=https://$(oc get route -n istio-system prometheus -o go-template="{{.spec.host}}")
PROMETHEUS_PASSWORD=$(oc get secret/htpasswd -n istio-system -o go-template="{{.data.rawPassword|base64decode}}")
TOKEN=$(oc sa new-token -n openshift-monitoring prometheus-k8s)

export PROMETHEUS_HOST PROMETHEUS_ISTIO_HOST PROMETHEUS_HOST TOKEN

if [[ ! -f /tmp/kube-burner-ocp ]]; then
  curl -sSL https://github.com/kube-burner/kube-burner-ocp/releases/download/v${KUBE_BURNER_VERSION}/kube-burner-ocp-V${KUBE_BURNER_VERSION}-linux-x86_64.tar.gz | tar xz -C /tmp/ kube-burner-ocp
fi

/tmp/kube-burner-ocp cluster-density-v2 ${@} --iterations=1
