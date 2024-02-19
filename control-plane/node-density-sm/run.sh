KUBE_BURNER_VERSION=1.1.0

export PROMETHEUS_HOST PROMETHEUS_ISTIO_HOST PROMETHEUS_HOST TOKEN

if [[ ! -f /tmp/kube-burner-ocp ]]; then
  curl -sSL https://github.com/kube-burner/kube-burner-ocp/releases/download/v${KUBE_BURNER_VERSION}/kube-burner-ocp-V${KUBE_BURNER_VERSION}-linux-x86_64.tar.gz | tar xz -C /tmp/ kube-burner-ocp
fi

/tmp/kube-burner-ocp node-density ${@}
cmd="/tmp/kube-burner-ocp node-density ${@}"
echo ${cmd}
exec ${cmd}
