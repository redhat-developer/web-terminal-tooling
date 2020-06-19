#!/bin/sh
set -e
set -x

PROJECT_ROOT=${PROJECT_ROOT:-$(pwd)}


TMP_CACHE_FLD=$PROJECT_ROOT/.tmp-download
CONTAINER_ROOT_FLD=$PROJECT_ROOT/.container-root
CONTAINER_OPT_FLD=$CONTAINER_ROOT_FLD/opt
CONTAINER_USR_BIN_FLD=$CONTAINER_ROOT_FLD/usr/local/bin
echo "Preparing cache folders: $TMP_CACHE_FLD $CONTAINER_ROOT_FLD"
rm -rf $TMP_CACHE_FLD
mkdir -p $TMP_CACHE_FLD
cd $TMP_CACHE_FLD

rm -rf $CONTAINER_ROOT_FLD
mkdir -p $CONTAINER_OPT_FLD
mkdir -p $CONTAINER_USR_BIN_FLD


export KUBECTX_VERSION=v0.9.0
echo "Dowloading Kubectx ${KUBECTX_VERSION}"
mkdir -p $CONTAINER_OPT_FLD/kubectx
wget -q -O- https://github.com/ahmetb/kubectx/archive/${KUBECTX_VERSION}.tar.gz | \
  tar xz --strip-components=1 -C $CONTAINER_OPT_FLD/kubectx

RH_PUBKEY_ID=199E2F91FD431D51
OPENSHIFT_CLIENTS_URL=https://mirror.openshift.com/pub/openshift-v4/clients
OC_VER=4.5.0-rc.1
HELM_VER=3.1.3
ODO_VER=v1.2.2
TKN_VER=0.9.0
KN_VER=0.13.2

echo "Dowloading OC ${OC_VER} and the corresponding kubectl"
curl -sSfL --insecure --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/sha256sum.txt.sig \
    ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/openshift-client-linux-${OC_VER}.tar.gz && \
    gpg --recv-keys ${RH_PUBKEY_ID} && gpg --input sha256sum.txt --verify sha256sum.txt.sig && \
    echo "$(grep openshift-client-linux-${OC_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) openshift-client-linux-${OC_VER}.tar.gz" | sha256sum --check --status && \
    tar xzf openshift-client-linux-${OC_VER}.tar.gz -C $CONTAINER_USR_BIN_FLD oc kubectl && \
    rm openshift-client-linux-${OC_VER}.tar.gz && \
    rm sha256sum.txt sha256sum.txt.sig

echo "Dowloading HELM ${HELM_VER}"
curl -sSfL --insecure --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/helm/${HELM_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/helm/${HELM_VER}/helm-linux-amd64 && \
    echo "$(grep helm-linux-amd64 sha256sum.txt | cut -d' ' -f1) helm-linux-amd64" | sha256sum --check --status && \
    mv helm-linux-amd64 $CONTAINER_USR_BIN_FLD/helm && chmod +x $CONTAINER_USR_BIN_FLD/helm && \
    rm sha256sum.txt

echo "Dowloading ODO ${ODO_VER}"
curl -sSfL --insecure --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/odo/${ODO_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/odo/${ODO_VER}/odo-linux-amd64.tar.gz && \
    echo "$(grep odo-linux-amd64.tar.gz sha256sum.txt | cut -d' ' -f1) odo-linux-amd64.tar.gz" | sha256sum --check --status && \
    tar xzf odo-linux-amd64.tar.gz -C $CONTAINER_USR_BIN_FLD odo && \
    rm odo-linux-amd64.tar.gz && \
    rm sha256sum.txt

echo "Dowloading TKN ${TKN_VER}"
curl -sSfL --insecure --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/pipeline/${TKN_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/pipeline/${TKN_VER}/tkn-linux-amd64-${TKN_VER}.tar.gz && \
    echo "$(grep tkn-linux-amd64-${TKN_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) tkn-linux-amd64-${TKN_VER}.tar.gz" | sha256sum --check --status && \
    tar xzf tkn-linux-amd64-${TKN_VER}.tar.gz -C $CONTAINER_USR_BIN_FLD tkn && \
    rm tkn-linux-amd64-${TKN_VER}.tar.gz && \
    rm sha256sum.txt

# Install kn
echo "Dowloading KN ${KN_VER}"
curl -sSfL --insecure --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/serverless/${KN_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/serverless/${KN_VER}/kn-linux-amd64-${KN_VER}.tar.gz && \
    echo "$(grep kn-linux-amd64-${KN_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) kn-linux-amd64-${KN_VER}.tar.gz" | sha256sum --check --status && \
    tar xzf kn-linux-amd64-${KN_VER}.tar.gz -C $CONTAINER_USR_BIN_FLD ./kn && chmod +x $CONTAINER_USR_BIN_FLD/kn && \
    rm kn-linux-amd64-${KN_VER}.tar.gz && \
    rm sha256sum.txt
