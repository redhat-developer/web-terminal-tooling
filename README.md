# Web Terminal Tooling

Default OpenShift Console Web Terminal tooling container.

Includes tools that enable a Kubernetes and OpenShift developer to interact with their cluster:
- [jq](https://github.com/stedolan/jq)
- [oc](https://github.com/openshift/origin) [4.13.0](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.12.0)
- [kubectl](https://github.com/kubernetes/kubectl) [v1.26.1](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.12.0)
- [kustomize](https://github.com/kubernetes-sigs/kustomize) [5.0.3](https://github.com/kubernetes-sigs/kustomize/tree/kustomize/v4.5.7)
- [helm](https://helm.sh/) [3.11.1](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/helm/3.9.0)
- [odo](https://github.com/openshift/odo) [v3.9.0](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/odo/v3.5.0)
- [tekton](https://github.com/tektoncd/cli) [0.30.1](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/pipeline/0.24.1)
- [knative](https://github.com/knative/client) [1.7.1](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/serverless/1.5.0)
- [rhoas](https://github.com/redhat-developer/app-services-cli) [0.53.0](https://github.com/redhat-developer/app-services-cli/tree/v0.52.0)
- [submariner](https://github.com/submariner-io/submariner) [0.14.4](https://github.com/submariner-io/subctl/tree/v0.14.1)
- [kubevirt](https://github.com/kubevirt/kubevirt) [0.59.0](https://github.com/kubevirt/kubevirt/tree/v0.58.0)

## Contributing

### How to build

Building the Web Terminal tooling container consists of two steps:
1. Download CLI binaries and pack them into a tarball (see `get-sources.sh`)
2. Build the container image using the Dockerfile in this repository

The `./build.sh` script can be used to automate the build process. By default, `podman` will be used to build the container image. See `./build.sh --help` for usage information.

### How to run

```bash
podman run -ti --rm web-terminal-tooling:local bash
```
