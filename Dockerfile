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

FROM registry.access.redhat.com/ubi8:8.2

USER 0

ENV JQ_VER=1.6 \
    JQ_PUBKEY_ID=4FD701D6FA9B3D2DF5AC935DAF19040C71523402 \
    RH_PUBKEY_ID=199E2F91FD431D51 \
    OPENSHIFT_CLIENTS_URL=https://mirror.openshift.com/pub/openshift-v4/clients \
    OC_VER=4.5.0-rc.1 \
    HELM_VER=3.1.3 \
    ODO_VER=v1.2.2 \
    TKN_VER=0.9.0 \
    KN_VER=0.13.2 \
    ISTIO_VERSION=1.6.1 \
    CRW_VERSION=2.1.1-GA \
    CRW_REVISION=78bf1fd

ENV HOME=/home/user

# NOTE: uncomment for local build. Must also set full registry path in FROM to registry.redhat.io or registry.access.redhat.com
# enable rhel 7 or 8 content sets (from Brew) to resolve jq as rpm
COPY ./content_set*.repo /etc/yum.repos.d/

RUN mkdir /home/user && \
    dnf install -y \
    # bash completion tools
    bash-completion ncurses pkgconf-pkg-config \
    # developer tools
    git wget tar procps jq \
    # is needed for install yq
    python2-pip python2-pip-wheel && \
    dnf -y clean all && \
    # install yq
    pip2 install yq && \
    # enable bash completion in interactive shells
    echo source /etc/profile.d/bash_completion.sh >> ~/.bashrc

# Install KubeCtx
RUN git clone https://github.com/ahmetb/kubectx.git /opt/kubectx && \
    cd /opt/kubectx && git checkout v0.9.0 && \
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens && \
    COMPDIR=$(pkg-config --variable=completionsdir bash-completion) && \
    ln -sf /opt/kubectx/completion/kubens.bash $COMPDIR/kubens && \
    ln -sf /opt/kubectx/completion/kubectx.bash $COMPDIR/kubectx

# Install oc and kubectl
RUN curl -sSfL --remote-name-all \
    ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/sha256sum.txt \
    ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/sha256sum.txt.sig \
    ${OPENSHIFT_CLIENTS_URL}/ocp/${OC_VER}/openshift-client-linux-${OC_VER}.tar.gz && \
    gpg --recv-keys ${RH_PUBKEY_ID} && gpg --input sha256sum.txt --verify sha256sum.txt.sig && \
    echo "$(grep openshift-client-linux-${OC_VER}.tar.gz sha256sum.txt | cut -d' ' -f1) openshift-client-linux-${OC_VER}.tar.gz" | sha256sum --check --status && \
    tar xzf openshift-client-linux-${OC_VER}.tar.gz -C /usr/local/bin oc kubectl && \
    rm openshift-client-linux-${OC_VER}.tar.gz && \
    rm sha256sum.txt sha256sum.txt.sig && \
    kubectl completion bash > $(pkg-config --variable=completionsdir bash-completion)/kubectl && \
    oc completion bash > $(pkg-config --variable=completionsdir bash-completion)/oc

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

# Install crwctl
RUN wget -O- https://github.com/redhat-developer/codeready-workspaces-chectl/releases/download/${CRW_VERSION}-${CRW_REVISION}/codeready-workspaces-${CRW_VERSION}-crwctl-linux-x64.tar.gz \
  | tar xvz -C /opt/ && \
  ln -s /opt/crwctl/bin/crwctl /usr/local/bin/crwctl && \
  printf "$(crwctl autocomplete:script bash)" >> ~/.bashrc

# Install istio
RUN cd /opt && \
  curl -L https://istio.io/downloadIstio | sh - && \
  ln -s /opt/istio-${ISTIO_VERSION}/bin/istio /usr/local/bin/istio

# Change permissions to let any arbitrary user
RUN for f in "${HOME}" "/etc/passwd"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done
ADD etc/entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
