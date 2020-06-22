# https://access.redhat.com/containers/?tab=tags#/registry.access.redhat.com/ubi8-minimal
#@local FROM registry.access.redhat.com/ubi8-minimal:8.2-301
#@Brew FROM ubi8-minimal:8.2-301
USER 0
ENV HOME=/home/user
WORKDIR /home/user

# NOTE: uncommented for local build.
# Enable rhel 7 or 8 content sets (from Brew) to resolve jq and bash-completion as rpm
#@local COPY ./content_set*.repo /etc/yum.repos.d/

RUN mkdir -p /home/user && \
    microdnf install -y \
    # bash completion tools
    bash-completion ncurses pkgconf-pkg-config \
    # developer tools
    curl git procps && \
    microdnf -y clean all && \
    # enable bash completion in interactive shells
    echo source /etc/profile.d/bash_completion.sh >> ~/.bashrc

ADD container-root.tgz /
# Propagate tools to path and install bash autocompletion
RUN \
    # Kubectx & Kubens
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens && \
    COMPDIR=$(pkg-config --variable=completionsdir bash-completion) && \
    ln -sf /opt/kubectx/completion/kubens.bash $COMPDIR/kubens && \
    ln -sf /opt/kubectx/completion/kubectx.bash $COMPDIR/kubectx && \
    # Install oc & kubectl & odo && kn && helm && tkn
    kubectl completion bash > $COMPDIR/kubectl && \
    oc completion bash > $COMPDIR/oc && \
    printf "complete -C /usr/local/bin/odo odo\n\n" >> ~/.bashrc && \
    kn completion bash > $COMPDIR/kn && \
    helm completion bash > $COMPDIR/kn && \
    tkn completion bash > $COMPDIR/tkn

# Change permissions to let any arbitrary user
RUN for f in "${HOME}" "/etc/passwd"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done
COPY etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

ENV SUMMARY="Web Terminal - Tooling container" \
    DESCRIPTION="Web Terminal - Tooling container" \
    PRODNAME="web-terminal" \
    COMPNAME="web-terminal-tooling"

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="$DESCRIPTION" \
      io.openshift.tags="$PRODNAME,$COMPNAME" \
      com.redhat.component="$PRODNAME-$COMPNAME-container" \
      name="$PRODNAME/$COMPNAME" \
      version="4.0" \
      license="EPLv2" \
      maintainer="Serhii Leshchenko <sleshche@redhat.com>" \
      io.openshift.expose-services="" \
      usage=""
