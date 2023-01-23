#!/bin/bash
#
# Copyright (c) 2020-2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#

OC_VER=$(oc version --client -o json | jq -r '.releaseClientVersion')
KUBECTL_VER=$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion')
if command -v kustomize &>/dev/null; then
  KUSTOMIZE_VER=$(kustomize version --short | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+')
else
  KUSTOMIZE_VER=$(kubectl version --client -o json | jq -r '.kustomizeVersion')
  BUILTIN_KUSTOMIZE="true"
fi
HELM_VER=$(helm version --short --template '{{.Version}}' 2>/dev/null)
KN_VER=$(kn version -o json | jq -r '.Version')
TKN_VER=$(tkn version --component client)
SUBMARINER_VER=$(subctl version | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+')
ODO_VER=$(odo version --client | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+')
RHOAS_VER=$(rhoas version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
KUBEVIRT_VER=$(virtctl version --client | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+')
JQ_VER=$(jq --version)
JQ_VER=${JQ_VER#jq-}

if [ "$BUILTIN_KUSTOMIZE" == "true" ]; then
  cat <<EOF | column -t -s '|'
Command  |Version        |Name
oc       |${OC_VER#v}        |OpenShift CLI
kubectl  |${KUBECTL_VER#v}   |Kubernetes CLI
kustomize|${KUSTOMIZE_VER#v} |Kustomize CLI (built-in to kubectl)
helm     |${HELM_VER#v}      |Helm CLI
kn       |${KN_VER#v}        |KNative CLI
tkn      |${TKN_VER#v}       |Tekton CLI
subctl   |${SUBMARINER_VER#v}|Submariner CLI
odo      |${ODO_VER#v}       |Red Hat OpenShift Developer CLI
rhoas    |${RHOAS_VER#v}     |Red Hat OpenShift Application Services CLI
virtctl  |${KUBEVIRT_VER#v}  |KubeVirt CLI
jq       |${JQ_VER#v}        |jq
EOF
else
  cat <<EOF | column -t -s '|'
Command  |Version        |Name
oc       |${OC_VER#v}        |OpenShift CLI
kubectl  |${KUBECTL_VER#v}   |Kubernetes CLI
kustomize|${KUSTOMIZE_VER#v} |Kustomize CLI
helm     |${HELM_VER#v}      |Helm CLI
kn       |${KN_VER#v}        |KNative CLI
tkn      |${TKN_VER#v}       |Tekton CLI
subctl   |${SUBMARINER_VER#v}|Submariner CLI
odo      |${ODO_VER#v}       |Red Hat OpenShift Developer CLI
rhoas    |${RHOAS_VER#v}     |Red Hat OpenShift Application Services CLI
virtctl  |${KUBEVIRT_VER#v}  |KubeVirt CLI
jq       |${JQ_VER#v}        |jq
EOF
fi
