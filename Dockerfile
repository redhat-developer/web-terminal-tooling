# https://access.redhat.com/containers/?tab=tags#/registry.access.redhat.com/ubi9-minimal
FROM registry.access.redhat.com/ubi9/ubi-minimal:9.7-1771346502
USER 0

# The $INITIAL_CONFIG dir stores dotfiles (e.g. .bashrc) for the web terminal, which
# are copied into $HOME when the container starts up. This allows defining a default
# configuration that can still be overridden if necessary (the copy does not overwrite
# existing files)
ENV INITIAL_CONFIG=/tmp/initial_config
ENV WRAPPER_BINARIES=/wto/bin
ENV DOWNLOADED_BINARIES=/wto/bin/downloaded
ENV HOME=/home/user
WORKDIR /home/user

RUN mkdir -p /home/user $INITIAL_CONFIG $WRAPPER_BINARIES $DOWNLOADED_BINARIES && \
    microdnf update -y --disablerepo=* --enablerepo=ubi-9-appstream-rpms --enablerepo=ubi-9-baseos-rpms && \
    microdnf install -y --disablerepo=* --enablerepo=ubi-9-appstream-rpms --enablerepo=ubi-9-baseos-rpms \
    # bash completion tools
    bash-completion ncurses pkgconf-pkg-config findutils \
    # zsh
    zsh \
    # terminal-based editors
    vi vim nano \
    # developer tools
    tar git procps jq && \
    microdnf -y clean all

COPY container-root-x86_64.tgz /tmp/container-root-x86_64.tgz

RUN tar --no-same-owner -xzf /tmp/container-root-x86_64.tgz -C / && \
    rm /tmp/container-root-x86_64.tgz

# Propagate tools to path and install bash autocompletion
RUN \
    COMPDIR=$(pkg-config --variable=completionsdir bash-completion) && \
    # install rhoas
    ln -s /opt/rhoas/rhoas /usr/local/bin/rhoas && \
    # install submariner
    ln -s /opt/submariner/subctl /usr/local/bin/subctl && \
    # install kubevirt
    ln -s /opt/kubevirt/virtctl /usr/local/bin/virtctl && \
    # install kustomize
    ln -s /opt/kustomize/kustomize /usr/local/bin/kustomize && \
    # make the bare 'helm' command default to helm v4 (helm3/helm4 remain available explicitly)
    # guard against a stale container-root tarball (rebuilt without ./build.sh -u), which would
    # lack helm4 and still carry an old bare 'helm' binary, making the symlink fail confusingly
    { test -x /usr/local/bin/helm4 || { echo "helm4 missing: please rebuild with ./build.sh -u" >&2; exit 1; }; } && \
    ln -s /usr/local/bin/helm4 /usr/local/bin/helm && \
    # install bash completions
    kubectl completion bash > $COMPDIR/kubectl && \
    oc completion bash > $COMPDIR/oc && \
    kn completion bash > $COMPDIR/kn && \
    helm completion bash > $COMPDIR/helm && \
    helm3 completion bash | sed 's/ helm$/ helm3/' > $COMPDIR/helm3 && \
    helm4 completion bash | sed 's/ helm$/ helm4/' > $COMPDIR/helm4 && \
    tkn completion bash > $COMPDIR/tkn && \
    virtctl completion bash > $COMPDIR/virtctl && \
    rhoas completion bash > $COMPDIR/rhoas && \
    subctl completion bash > $COMPDIR/subctl

COPY etc/initial_config /tmp/initial_config
COPY etc/get-tooling-versions.sh /tmp/get-tooling-versions.sh
COPY ["etc/wtoctl", "etc/wtoctl_help.sh", "etc/wtoctl_jq.sh", "/usr/local/bin/"]
COPY ["etc/cli-wrappers/*", "${WRAPPER_BINARIES}/"]
COPY etc/entrypoint.sh /entrypoint.sh

# Change permissions to let root group access necessary files
RUN for f in "${HOME}" "${INITIAL_CONFIG}" "${WRAPPER_BINARIES}" "${DOWNLOADED_BINARIES}" "/etc/passwd" "/etc/group"; do \
    echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
    chmod -R g+rwX ${f}; \
    done && \
    /tmp/get-tooling-versions.sh > /tmp/installed_tools.txt && \
    chmod g+rw /tmp/installed_tools.txt && \
    echo "Installed tools:" && \
    cat /tmp/installed_tools.txt

USER 1001

ENV SHELL=/bin/bash
ENV PATH="${WRAPPER_BINARIES}:${DOWNLOADED_BINARIES}:${PATH}"

ENTRYPOINT [ "/entrypoint.sh" ]

ENV SUMMARY="Web Terminal - Tooling container" \
    DESCRIPTION="Web Terminal - Tooling container" \
    PRODNAME="web-terminal" \
    COMPNAME="tooling"

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="$DESCRIPTION" \
      io.openshift.tags="$PRODNAME,$COMPNAME" \
      com.redhat.component="$PRODNAME-$COMPNAME-container" \
      name="$PRODNAME/$COMPNAME" \
      version="${CI_X_VERSION}.${CI_Y_VERSION}" \
      license="EPLv2" \
      maintainer="David Kwon <dakwon@redhat.com>" \
      io.openshift.expose-services="" \
      usage=""
