# https://access.redhat.com/containers/?tab=tags#/registry.access.redhat.com/ubi8-minimal
#@local FROM registry.access.redhat.com/ubi8-minimal:8.5-230
#@brew FROM ubi8-minimal:8.5-230
USER 0

# The $INITIAL_CONFIG dir stores dotfiles (e.g. .bashrc) for the web terminal, which
# are copied into $HOME when the container starts up. This allows defining a default
# configuration that can still be overridden if necessary (the copy does not overwrite
# existing files)
ENV INITIAL_CONFIG=/tmp/initial_config
ENV HOME=/home/user
WORKDIR /home/user

RUN mkdir -p /home/user $INITIAL_CONFIG && \
    microdnf install -y \
    # bash completion tools
    bash-completion ncurses pkgconf-pkg-config findutils \
    # terminal-based editors
    vi vim nano \
    # developer tools
#@brew     mc \
    curl git procps jq && \
    microdnf -y clean all

ADD container-root-x86_64.tgz /
# Propagate tools to path and install bash autocompletion
RUN \
    # Kubectx & Kubens
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens && \
    COMPDIR=$(pkg-config --variable=completionsdir bash-completion) && \
    ln -sf /opt/kubectx/completion/kubens.bash $COMPDIR/kubens && \
    ln -sf /opt/kubectx/completion/kubectx.bash $COMPDIR/kubectx && \
    # install rhoas
    ln -s /opt/rhoas/rhoas /usr/local/bin/rhoas && \
    rhoas completion bash > $COMPDIR/rhoas && \
    # install submariner
    ln -s /opt/submariner/subctl /usr/local/bin/subctl && \
    # Install oc & kubectl & odo && kn && helm && tkn
    kubectl completion bash > $COMPDIR/kubectl && \
    oc completion bash > $COMPDIR/oc && \
    kn completion bash > $COMPDIR/kn && \
    helm completion bash > $COMPDIR/helm && \
    tkn completion bash > $COMPDIR/tkn

COPY etc/initial_config /tmp/initial_config
COPY tooling_versions.env /tmp/tooling_versions.env
# Change permissions to let any arbitrary user
RUN for f in "${HOME}" "${INITIAL_CONFIG}" "/etc/passwd" "/etc/group"; do \
    echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
    chmod -R g+rwX ${f}; \
    done
COPY etc/entrypoint.sh /entrypoint.sh

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
      version="1.4" \
      license="EPLv2" \
      maintainer="Angel Misevski <amisevsk@redhat.com>" \
      io.openshift.expose-services="" \
      usage=""
