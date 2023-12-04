# Web Terminal Tooling

Default OpenShift Console Web Terminal tooling container.

Includes tools that enable a Kubernetes and OpenShift developer to interact with their cluster:
- [jq](https://github.com/stedolan/jq)
- [oc](https://github.com/openshift/origin) [v4.14.5](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.14.5)
- [kubectl](https://github.com/kubernetes/kubectl) [v1.27.4](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.14.5)
- [kustomize](https://github.com/kubernetes-sigs/kustomize) [v5.2.1](https://github.com/kubernetes-sigs/kustomize/tree/kustomize/v5.2.1)
- [helm](https://helm.sh/) [v3.12.1](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/helm/3.12.1)
- [odo](https://github.com/openshift/odo) [v3.15.0](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/odo/v3.15.0)
- [tekton](https://github.com/tektoncd/cli) [v1.13.0](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/pipeline/1.13.0)
- [knative](https://github.com/knative/client) [v1.9.2](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/serverless/1.9.2)
- [rhoas](https://github.com/redhat-developer/app-services-cli) [v0.53.0](https://github.com/redhat-developer/app-services-cli/tree/v0.53.0)
- [submariner](https://github.com/submariner-io/submariner) [v0.16.2](https://github.com/submariner-io/subctl/tree/v0.16.2)
- [kubevirt](https://github.com/kubevirt/kubevirt) [v1.1.0](https://github.com/kubevirt/kubevirt/tree/v1.1.0)

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
