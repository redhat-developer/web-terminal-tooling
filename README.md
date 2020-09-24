# Web Terminal Tooling

Default OpenShift Console Web Terminal tooling container.

Includes tools that a Kubernetes and OpenShift developer would like find in their terminal:
- [jq](https://github.com/stedolan/jq)
- [oc](https://github.com/openshift/origin) [4.6.1](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.6.1/)
- [kubectl](https://github.com/kubernetes/kubectl) [v1.19.0](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.6.1/)
- [odo](https://github.com/openshift/odo) [v2.0.0](https://mirror.openshift.com/pub/openshift-v4/clients/odo/v2.0.0/)
- [helm](https://helm.sh/) [v3.3.4](https://mirror.openshift.com/pub/openshift-v4/clients/helm/3.3.4/)
- [KNative](https://github.com/knative/client) [v0.16.1](https://mirror.openshift.com/pub/openshift-v4/clients/serverless/0.16.1/)
- [Tekton CLI](https://github.com/tektoncd/cli) [0.11.0](https://mirror.openshift.com/pub/openshift-v4/clients/pipeline/0.11.0/)
- [kubectx & kubens](https://github.com/ahmetb/kubectx) [v0.9.1](https://github.com/ahmetb/kubectx/releases/tag/v0.9.1)

## Contributing

### How to build

There is [template.Dockerfile](https://github.com/redhat-developer/web-terminal-tooling/blob/master/build/template.Dockerfile) that is processed by build.sh script to apply needed changes before build. So, execute the following but before uncomment configuration params if needed.

```bash
# TOOL=podman # can be docker
# MODE=local # can be brew
# WEB_TERMINAL_TOOLING_IMG=web-terminal-tooling:local
./build.sh
```

### How to run

```bash
podman run -ti --rm web-terminal-tooling:local bash
```
