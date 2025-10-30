#!/bin/bash
#
# Copyright (c) 2020-2024 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#

INSTALLED_TOOLS="Command |Version |Name"

function append_ver() {
  INSTALLED_TOOLS="$INSTALLED_TOOLS\n$1"
}

OC_VER=$(oc version --client -o json | jq -r '.clientVersion.gitVersion' | grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+')
append_ver "oc       |${OC_VER#v}        |OpenShift CLI"

KUBECTL_VER=$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion' | grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+')
append_ver "kubectl  |${KUBECTL_VER#v}   |Kubernetes CLI"

if command -v kustomize &>/dev/null; then
  KUSTOMIZE_VER=$(kustomize version | grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+')
  append_ver "kustomize|${KUSTOMIZE_VER#v} |Kustomize CLI"
else
  KUSTOMIZE_VER=$(kubectl version --client -o json | jq -r '.kustomizeVersion')
  append_ver "kustomize|${KUSTOMIZE_VER#v} |Kustomize CLI (built-in to kubectl)"
fi

if command -v helm &>/dev/null; then
  HELM_VER=$(helm version --short --template '{{.Version}}' 2>/dev/null | grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+')
  append_ver "helm     |${HELM_VER#v}      |Helm CLI"
fi

if command -v kn &>/dev/null; then
  KN_VER=$(kn version -o json | jq -r '.Version')
  append_ver "kn       |${KN_VER#v}        |KNative CLI"
fi

if command -v tkn &>/dev/null; then
  TKN_VER=$(tkn version --component client)
  append_ver "tkn      |${TKN_VER#v}       |Tekton CLI"
fi

if command -v subctl &>/dev/null; then
  SUBMARINER_VER=$(subctl version | grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+|release-[0-9]+\.[0-9]+')
  append_ver "subctl   |${SUBMARINER_VER#v}|Submariner CLI"
fi

if command -v virtctl &>/dev/null; then
  KUBEVIRT_VER=$(virtctl version --client | grep -Eo 'GitVersion:"[^"]+"' | grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+')
  append_ver "virtctl  |${KUBEVIRT_VER#v}  |KubeVirt CLI"
fi

if command -v rhoas &>/dev/null; then
  RHOAS_VER=$(rhoas version | grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+')
  append_ver "rhoas    |${RHOAS_VER#v}     |Red Hat OpenShift Application Services CLI"
fi

JQ_VER=$(jq --version)
JQ_VER=${JQ_VER#jq-}
append_ver "jq       |${JQ_VER#v}        |jq"

echo -e "$INSTALLED_TOOLS" | column -t -s '|'
