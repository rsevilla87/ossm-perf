NETPERF_VERSION=0.1.22
curl -sSL https://github.com/cloud-bulldozer/k8s-netperf/releases/download/v${NETPERF_VERSION}/k8s-netperf_Linux_v${NETPERF_VERSION}_x86_64.tar.gz | tar xzf - k8s-netperf
oc create ns netperf 2>/dev/null
oc label namespace netperf istio.io/dataplane-mode=ambient
oc create sa netperf -n netperf
oc adm policy add-scc-to-user hostnetwork -z netperf -n netperf
if [[ $2 != "" ]]; then
  ./k8s-netperf --clean=false --config ${1} --search ${2} --csv=false
else
  ./k8s-netperf --clean=false --config ${1} --csv=false
fi
oc delete ns netperf
