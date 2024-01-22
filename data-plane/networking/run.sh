SIDECAR=${SIDECAR:?}
curl -sSL https://github.com/cloud-bulldozer/k8s-netperf/releases/download/v0.1.20/k8s-netperf_Linux_v0.1.20_x86_64.tar.gz | tar xzf - k8s-netperf
oc create ns netperf 2>/dev/null
if [[ ${SIDECAR} == "true" ]]; then
  echo "Adding istio-injection=enabled label to ns"
  oc label ns netperf istio-injection=enabled --overwrite
fi
oc create sa netperf -n netperf
oc adm policy add-scc-to-user hostnetwork -z netperf -n netperf
if [[ $2 != "" ]]; then
  ./k8s-netperf --all --config ${1} --search ${2}
else
  ./k8s-netperf --all --config ${1}
fi
oc delete ns netperf
