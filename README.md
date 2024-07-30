# Web Terminal Tooling

Default OpenShift Console Web Terminal tooling container.

Includes tools that enable a Kubernetes and OpenShift developer to interact with their cluster:
- [jq](https://github.com/stedolan/jq)
- [oc](https://github.com/openshift/origin) [v4.16.0](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.16.0)
- [kubectl](https://github.com/kubernetes/kubectl) [v1.29.1](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.16.0)
- [kustomize](https://github.com/kubernetes-sigs/kustomize) [v5.4.2](https://github.com/kubernetes-sigs/kustomize/tree/kustomize/v5.4.2)
- [helm](https://helm.sh/) [v3.14.4](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/helm/3.14.4)
- [tekton](https://github.com/tektoncd/cli) [v1.15.0](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/pipelines/1.15.0)
- [knative](https://github.com/knative/client) [v1.12.0](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/serverless/1.12.0)
- [rhoas](https://github.com/redhat-developer/app-services-cli) [v0.53.0](https://github.com/redhat-developer/app-services-cli/tree/v0.53.0)
- [submariner](https://github.com/submariner-io/submariner) [v0.17.2](https://github.com/submariner-io/subctl/tree/v0.17.2)
- [kubevirt](https://github.com/kubevirt/kubevirt) [v1.2.2](https://github.com/kubevirt/kubevirt/tree/v1.2.2)

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
