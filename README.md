# Web Terminal Tooling

Default OpenShift Console Web Terminal tooling container.

Includes tools that a Kubernetes and OpenShift developer would like find in their terminal:
- [jq](https://github.com/stedolan/jq)
- [yq](https://kislyuk.github.io/yq/)
- [oc](https://github.com/openshift/origin) [4.5.0-rc.1](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.5.0-rc.1/)
- [kubectl](https://github.com/kubernetes/kubectl) [v1.18.2-0-g52c56ce](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.5.0-rc.1/)
- [odo](https://github.com/openshift/odo) [v1.2.2](https://mirror.openshift.com/pub/openshift-v4/clients/odo/v1.2.2/)
- [helm](https://helm.sh/) [v3.1.3](https://mirror.openshift.com/pub/openshift-v4/clients/helm/3.1.3/)
- [KNative](https://github.com/knative/client) [v0.13.2](https://mirror.openshift.com/pub/openshift-v4/clients/serverless/0.13.2/)
- [Tekton CLI](https://github.com/tektoncd/cli) [0.9.0](https://mirror.openshift.com/pub/openshift-v4/clients/pipeline/0.9.0/)
- [kubectx & kubens](https://github.com/ahmetb/kubectx) [v0.9.0](https://github.com/ahmetb/kubectx/releases/tag/v0.9.0)
- [istioctl](https://github.com/istio/istio) [1.6.1](https://github.com/istio/istio/releases/tag/1.6.1)
- [crwctl](https://github.com/redhat-developer/codeready-workspaces-chectl) [2.1.1-GA-78bf1fd](https://github.com/redhat-developer/codeready-workspaces-chectl/releases/tag/2.1.1-GA-78bf1fd)

## Contributing

### How to build

```bash
docker build -t web-terminal-tooling .
```

### How to run

```bash
docker run -ti --rm web-terminal-tooling
```
