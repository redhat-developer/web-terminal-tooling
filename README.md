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
- [kubectx & kubens](https://github.com/ahmetb/kubectx) [v0.9.4](https://github.com/ahmetb/kubectx/releases/tag/v0.9.4)
- [rhoas](https://github.com/redhat-developer/app-services-cli) [0.34.2](https://github.com/redhat-developer/app-services-cli/releases/tag/0.34.2)
- [submariner](https://github.com/submariner-io/submariner) [v0.10.1](https://github.com/submariner-io/submariner/releases/tag/v0.10.1)

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

Upstream and downstream are synced via this [job](https://codeready-workspaces-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/web-terminal-sync-web-terminal-tooling/)
