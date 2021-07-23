#!/bin/bash

set -e

updateSourcesFlag="false"
printHelp="false"
while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-u'|'--update-sources') updateSourcesFlag="true"; shift 0;;
    '-h'|'--help') printHelp="true"; shift 0;;
  esac
  shift 1
done

if [[ "$printHelp" == "true" ]]; then
  echo "Usage:"
  echo "-u, --update-sources - Update lookaside cache"
  echo "-h, --help - print this message"
  exit 0
fi

PROJECT_ROOT=${PROJECT_ROOT:-$(cd "$(dirname "$0")" || exit; pwd)}
CONTAINER_ROOT_RELATIVE_PATH=".container-root"
CONTAINER_ROOT_DIR="${PROJECT_ROOT}/${CONTAINER_ROOT_RELATIVE_PATH}"
CONTAINER_OPT_DIR=$CONTAINER_ROOT_DIR/opt
CONTAINER_USR_BIN_DIR=$CONTAINER_ROOT_DIR/usr/local/bin

rm -rf "${CONTAINER_ROOT_DIR:?}"
mkdir -p "$CONTAINER_ROOT_DIR" "$CONTAINER_OPT_DIR" "$CONTAINER_USR_BIN_DIR"

OC_VER=4.8.2
HELM_VER=3.5.0
ODO_VER=v2.2.3
TKN_VER=0.17.2
KN_VER=0.21.0
KUBECTX_VERSION=v0.9.4
RHOAS_VERSION=0.25.0
SUBMARINER_VERSION=0.9.1

OPENSHIFT_CLIENTS_URL=https://mirror.openshift.com/pub/openshift-v4/x86_64/clients

# Work in a /tmp/ directory
TMPDIR=$(mktemp -d)
echo "Using tmp dir ${TMPDIR}"
cd "$TMPDIR"

echo "Downloading oc ${OC_VER} and the corresponding kubectl"
curl -sSfL --insecure --remote-name-all \
  ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/sha256sum.txt \
  ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/openshift-client-linux-${OC_VER}.tar.gz
echo "$(grep openshift-client-linux-${OC_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) openshift-client-linux-${OC_VER}.tar.gz" | sha256sum --check --status
tar xzf openshift-client-linux-${OC_VER}.tar.gz -C "$CONTAINER_USR_BIN_DIR" oc kubectl

KUBECTL_V=$($CONTAINER_USR_BIN_DIR/kubectl version --client=true -o=json | jq -r '.clientVersion.gitVersion')
# Kubectl version has vMajor.Manor.BugFix-Build-GitRevision, like v1.20.1-5-g76a04fc
# Cut build number and git revision
KUBECTL_VER=${KUBECTL_V%-*-*}
echo "Extracted kubectl ${KUBECTL_VER}"

rm -rf "${TMPDIR:?}"/*

echo "Downloading helm ${HELM_VER}"
curl -sSfL --insecure --remote-name-all \
  ${OPENSHIFT_CLIENTS_URL}/helm/${HELM_VER}/sha256sum.txt \
  ${OPENSHIFT_CLIENTS_URL}/helm/${HELM_VER}/helm-linux-amd64
echo "$(grep helm-linux-amd64$ sha256sum.txt | cut -d' ' -f1) helm-linux-amd64" | sha256sum --check --status
mv helm-linux-amd64 "$CONTAINER_USR_BIN_DIR/helm"
rm -rf "${TMPDIR:?}"/*

echo "Downloading odo ${ODO_VER}"
curl -sSfL --insecure --remote-name-all \
  ${OPENSHIFT_CLIENTS_URL}/odo/${ODO_VER}/sha256sum.txt \
  ${OPENSHIFT_CLIENTS_URL}/odo/${ODO_VER}/odo-linux-amd64.tar.gz
echo "$(grep odo-linux-amd64.tar.gz sha256sum.txt | cut -d' ' -f1) odo-linux-amd64.tar.gz" | sha256sum --check --status
tar xzf odo-linux-amd64.tar.gz -C "$CONTAINER_USR_BIN_DIR" odo
rm -rf "${TMPDIR:?}"/*

echo "Downloading tekton ${TKN_VER}"
curl -sSfL --insecure --remote-name-all \
  ${OPENSHIFT_CLIENTS_URL}/pipeline/${TKN_VER}/sha256sum.txt \
  ${OPENSHIFT_CLIENTS_URL}/pipeline/${TKN_VER}/tkn-linux-amd64-${TKN_VER}.tar.gz
echo "$(grep tkn-linux-amd64-${TKN_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) tkn-linux-amd64-${TKN_VER}.tar.gz" | sha256sum --check --status
tar xzf tkn-linux-amd64-${TKN_VER}.tar.gz -C "$CONTAINER_USR_BIN_DIR" tkn
rm -rf "${TMPDIR:?}"/*

echo "Downloading knative ${KN_VER}"
curl -sSfL --insecure --remote-name-all \
  ${OPENSHIFT_CLIENTS_URL}/serverless/${KN_VER}/sha256sum.txt \
  ${OPENSHIFT_CLIENTS_URL}/serverless/${KN_VER}/kn-linux-amd64.tar.gz
echo "$(grep kn-linux-amd64.tar.gz sha256sum.txt | cut -d' ' -f1) kn-linux-amd64.tar.gz" | sha256sum --check --status && \
tar xzf kn-linux-amd64.tar.gz -C "$CONTAINER_USR_BIN_DIR" kn
rm -rf "${TMPDIR:?}"/*

echo "Downloading kubectx ${KUBECTX_VERSION}"
mkdir -p "$CONTAINER_OPT_DIR/kubectx"
wget -q -O- https://github.com/ahmetb/kubectx/archive/${KUBECTX_VERSION}.tar.gz | \
  tar xz --strip-components=1 -C "$CONTAINER_OPT_DIR/kubectx"
rm -rf "${TMPDIR:?}"/*

echo "Downloading rhoas ${RHOAS_VERSION}"
mkdir -p "$CONTAINER_OPT_DIR/rhoas"
wget -q -O- https://github.com/redhat-developer/app-services-cli/releases/download/v${RHOAS_VERSION}/rhoas_${RHOAS_VERSION}_linux_amd64.tar.gz | \
  tar xz --strip-components=1 -C "$CONTAINER_OPT_DIR/rhoas"
rm -rf "${TMPDIR:?}"/*
chmod -R +x "${CONTAINER_USR_BIN_DIR}"

echo "Downloading submariner ${SUBMARINER_VERSION}"
mkdir -p "$CONTAINER_OPT_DIR/submariner"
wget -q -O- https://github.com/submariner-io/submariner-operator/releases/download/v${SUBMARINER_VERSION}/subctl-release-0.9-c2a7e5d-linux-amd64.tar.xz | \
  tar xJ --strip-components=1 -C "$CONTAINER_OPT_DIR/submariner"
mv "$CONTAINER_OPT_DIR"/submariner/subctl* "$CONTAINER_OPT_DIR"/submariner/subctl
rm -rf "${TMPDIR:?}"/*
chmod -R +x "${CONTAINER_USR_BIN_DIR}"

cd "$PROJECT_ROOT"
tar -czf container-root-x86_64.tgz -C "$CONTAINER_ROOT_RELATIVE_PATH" .
if [[ "$updateSourcesFlag" = "true" ]]; then
  rhpkg new-sources container-root-x86_64.tgz
fi

rm -f rh-manifests.txt || true
{
  echo "oc ${OC_VER} ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}"
  echo "kubectl ${KUBECTL_VER} ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}"
  echo "helm ${HELM_VER} ${OPENSHIFT_CLIENTS_URL}/helm/${HELM_VER}"
  echo "odo ${ODO_VER} ${OPENSHIFT_CLIENTS_URL}/odo/${ODO_VER}"
  echo "tekton ${TKN_VER} ${OPENSHIFT_CLIENTS_URL}/pipeline/${TKN_VER}"
  echo "knative ${KN_VER} ${OPENSHIFT_CLIENTS_URL}/serverless/${KN_VER}"
  echo "kubectx ${KUBECTX_VERSION} https://github.com/ahmetb/kubectx/tree/${KUBECTX_VERSION}"
  echo "kubens ${KUBECTX_VERSION} https://github.com/ahmetb/kubectx/tree/${KUBECTX_VERSION}"
  echo "rhoas ${RHOAS_VERSION} https://github.com/redhat-developer/app-services-cli/tree/${RHOAS_VERSION}"
  echo "submariner ${SUBMARINER_VERSION} https://github.com/submariner-io/submariner-operator/tree/v${SUBMARINER_VERSION}"
} >> rh-manifests.txt

rm -rf "$CONTAINER_ROOT_DIR"
