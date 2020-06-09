# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#

FROM registry.access.redhat.com/ubi8-minimal:8.2

ENV OC_VER=4.5.0-rc.1
ENV HELM_VER=3.1.3
ENV ODO_VER=v1.2.2
ENV TKN_VER=0.9.0
ENV KN_VER=0.13.2
ENV JQ_VER=1.6
ENV RH_PUBKEY_ID=199E2F91FD431D51
ENV JQ_PUBKEY_ID=4FD701D6FA9B3D2DF5AC935DAF19040C71523402
ENV OPENSHIFT_CLIENTS_URL=https://mirror.openshift.com/pub/openshift-v4/clients

RUN microdnf update && microdnf install -y git vim tar

# Install oc and kubectl
RUN curl -sSfL --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/sha256sum.txt.sig \ 
    ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/openshift-client-linux-${OC_VER}.tar.gz && \
    gpg --recv-keys ${RH_PUBKEY_ID} && gpg --input sha256sum.txt --verify sha256sum.txt.sig && \
    echo "$(grep openshift-client-linux-${OC_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) openshift-client-linux-${OC_VER}.tar.gz" | sha256sum --check --status && \
    tar xzf openshift-client-linux-${OC_VER}.tar.gz -C /usr/local/bin oc kubectl && \
    rm openshift-client-linux-${OC_VER}.tar.gz && \
    rm sha256sum.txt sha256sum.txt.sig

# Install helm
RUN curl -sSfL --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/helm/${HELM_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/helm/${HELM_VER}/helm-linux-amd64 && \
    echo "$(grep helm-linux-amd64 sha256sum.txt | cut -d' ' -f1) helm-linux-amd64" | sha256sum --check --status && \
    mv helm-linux-amd64 /usr/local/bin/helm && chmod +x /usr/local/bin/helm && \
    rm sha256sum.txt

# Install odo
RUN curl -sSfL --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/odo/${ODO_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/odo/${ODO_VER}/odo-linux-amd64.tar.gz && \
    echo "$(grep odo-linux-amd64.tar.gz sha256sum.txt | cut -d' ' -f1) odo-linux-amd64.tar.gz" | sha256sum --check --status && \
    tar xzf odo-linux-amd64.tar.gz -C /usr/local/bin odo && \
    rm odo-linux-amd64.tar.gz && \
    rm sha256sum.txt

# Install tkn
RUN curl -sSfL --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/pipeline/${TKN_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/pipeline/${TKN_VER}/tkn-linux-amd64-${TKN_VER}.tar.gz && \
    echo "$(grep tkn-linux-amd64-${TKN_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) tkn-linux-amd64-${TKN_VER}.tar.gz" | sha256sum --check --status && \
    tar xzf tkn-linux-amd64-${TKN_VER}.tar.gz -C /usr/local/bin tkn && \
    rm tkn-linux-amd64-${TKN_VER}.tar.gz && \
    rm sha256sum.txt

# Install kn
RUN curl -sSfL --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/serverless/${KN_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/serverless/${KN_VER}/kn-linux-amd64-${KN_VER}.tar.gz && \
    echo "$(grep kn-linux-amd64-${KN_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) kn-linux-amd64-${KN_VER}.tar.gz" | sha256sum --check --status && \
    tar xzf kn-linux-amd64-${KN_VER}.tar.gz -C /usr/local/bin ./kn && chmod +x /usr/local/bin/kn && \ 
    rm kn-linux-amd64-${KN_VER}.tar.gz && \
    rm sha256sum.txt 

# Install jq
RUN curl -sSfL --remote-name-all \
    https://github.com/stedolan/jq/releases/download/jq-${JQ_VER}/jq-linux64 \
    https://raw.githubusercontent.com/stedolan/jq/master/sig/v${JQ_VER}/sha256sum.txt \
    https://raw.githubusercontent.com/stedolan/jq/master/sig/v${JQ_VER}/jq-linux64.asc && \
    gpg --recv-keys ${JQ_PUBKEY_ID} && gpg --verify jq-linux64.asc && \
    echo "$(grep jq-linux64 sha256sum.txt | cut -d' ' -f1) jq-linux64" | sha256sum --check --status && \
    mv jq-linux64 /usr/local/bin/jq && chmod +x /usr/local/bin/jq && \
    rm sha256sum.txt jq-linux64.asc
    
