# Web Terminal Tooling

Default OpenShift Console Web Terminal tooling container.

Includes tools that a Kubernetes and OpenShift developer would like find in their terminal:
- [jq](https://github.com/stedolan/jq)
- [oc](https://github.com/openshift/origin) [4.9.0](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.9.0)
- [kubectl](https://github.com/kubernetes/kubectl) [v0.21.0-beta.1](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.8.3)
- [odo](https://github.com/openshift/odo) [v2.3.1](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/odo/v2.3.1)
- [helm](https://helm.sh/) [3.6.2](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/helm/3.6.2)
- [KNative](https://github.com/knative/client) [v0.23.0](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/serverless/0.23.0)
- [Tekton CLI](https://github.com/tektoncd/cli) [0.19.1](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/pipeline/0.17.2)
- [rhoas](https://github.com/redhat-developer/app-services-cli) [0.34.2](https://github.com/redhat-developer/app-services-cli/releases/tag/0.34.2)
- [submariner](https://github.com/submariner-io/submariner) [v0.12.1](https://github.com/submariner-io/submariner/releases/tag/v0.12.1)

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
