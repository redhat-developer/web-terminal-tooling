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

OC_VER=4.5.3
HELM_VER=3.2.3
ODO_VER=v1.2.4
TKN_VER=0.9.0
KN_VER=0.13.2
KUBECTX_VERSION=v0.9.1

RH_PUBKEY_ID=199E2F91FD431D51
OPENSHIFT_CLIENTS_URL=https://mirror.openshift.com/pub/openshift-v4/clients

# Work in a /tmp/ directory
TMPDIR=$(mktemp -d)
echo "Using tmp dir ${TMPDIR}"
cd "$TMPDIR"

echo "Downloading oc ${OC_VER} and the corresponding kubectl"
curl -sSfL --insecure --remote-name-all \
  ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/sha256sum.txt \
  ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/sha256sum.txt.sig \
  ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/openshift-client-linux-${OC_VER}.tar.gz
gpg --recv-keys ${RH_PUBKEY_ID} && gpg --input sha256sum.txt --verify sha256sum.txt.sig
echo "$(grep openshift-client-linux-${OC_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) openshift-client-linux-${OC_VER}.tar.gz" | sha256sum --check --status
tar xzf openshift-client-linux-${OC_VER}.tar.gz -C "$CONTAINER_USR_BIN_DIR" oc kubectl
rm -rf "${TMPDIR:?}"/*

echo "Downloading helm ${HELM_VER}"
curl -sSfL --insecure --remote-name-all \
  ${OPENSHIFT_CLIENTS_URL}/helm/${HELM_VER}/sha256sum.txt \
  ${OPENSHIFT_CLIENTS_URL}/helm/${HELM_VER}/helm-linux-amd64
echo "$(grep helm-linux-amd64 sha256sum.txt | cut -d' ' -f1) helm-linux-amd64" | sha256sum --check --status
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
  ${OPENSHIFT_CLIENTS_URL}/serverless/${KN_VER}/kn-linux-amd64-${KN_VER}.tar.gz
echo "$(grep kn-linux-amd64-${KN_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) kn-linux-amd64-${KN_VER}.tar.gz" | sha256sum --check --status && \
tar xzf kn-linux-amd64-${KN_VER}.tar.gz -C "$CONTAINER_USR_BIN_DIR" ./kn
rm -rf "${TMPDIR:?}"/*

echo "Downloading kubectx ${KUBECTX_VERSION}"
mkdir -p "$CONTAINER_OPT_DIR/kubectx"
wget -q -O- https://github.com/ahmetb/kubectx/archive/${KUBECTX_VERSION}.tar.gz | \
  tar xz --strip-components=1 -C "$CONTAINER_OPT_DIR/kubectx"
rm -rf "${TMPDIR:?}"/*

chmod -R +x "${CONTAINER_USR_BIN_DIR}"

cd "$PROJECT_ROOT"
tar -czf container-root-x86_64.tgz -C "$CONTAINER_ROOT_RELATIVE_PATH" .
if [[ "$updateSourcesFlag" = "true" ]]; then
  rhpkg new-sources container-root-x86_64.tgz
fi

rm -rf "$CONTAINER_ROOT_DIR"
