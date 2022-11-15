# https://access.redhat.com/containers/?tab=tags#/registry.access.redhat.com/ubi8-minimal
FROM registry.access.redhat.com/ubi8-minimal:8.6-902
USER 0

# The $INITIAL_CONFIG dir stores dotfiles (e.g. .bashrc) for the web terminal, which
# are copied into $HOME when the container starts up. This allows defining a default
# configuration that can still be overridden if necessary (the copy does not overwrite
# existing files)
ENV INITIAL_CONFIG=/tmp/initial_config
ENV HOME=/home/user
WORKDIR /home/user

RUN mkdir -p /home/user $INITIAL_CONFIG && \
    microdnf update -y --disablerepo=* --enablerepo=ubi-8-appstream --enablerepo=ubi-8-baseos && \
    microdnf install -y --disablerepo=* --enablerepo=ubi-8-appstream --enablerepo=ubi-8-baseos \
    # bash completion tools
    bash-completion ncurses pkgconf-pkg-config findutils \
    # terminal-based editors
    vi vim nano \
    # developer tools
    curl tar git procps jq && \
    microdnf -y clean all

ADD container-root-x86_64.tgz /
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
    # install bash completions
    kubectl completion bash > $COMPDIR/kubectl && \
    oc completion bash > $COMPDIR/oc && \
    kn completion bash > $COMPDIR/kn && \
    helm completion bash > $COMPDIR/helm && \
    tkn completion bash > $COMPDIR/tkn && \
    virtctl completion bash > $COMPDIR/virtctl && \
    rhoas completion bash > $COMPDIR/rhoas && \
    subctl completion bash > $COMPDIR/subctl

COPY etc/initial_config /tmp/initial_config
COPY tooling_versions.env /tmp/tooling_versions.env
COPY ["etc/wtoctl", "etc/wtoctl_help.sh", "etc/wtoctl_jq.sh", "/usr/local/bin/"]
COPY etc/entrypoint.sh /entrypoint.sh

# Change permissions to let root group access necessary files
RUN for f in "${HOME}" "${INITIAL_CONFIG}" "/etc/passwd" "/etc/group"; do \
    echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
    chmod -R g+rwX ${f}; \
    done

USER 1001
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
      version="1.6" \
      license="EPLv2" \
      maintainer="Angel Misevski <amisevsk@redhat.com>" \
      io.openshift.expose-services="" \
      usage=""
