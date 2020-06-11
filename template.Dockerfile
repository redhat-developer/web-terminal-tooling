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

#@local FROM registry.access.redhat.com/ubi8-minimal:8.2
#@Brew FROM ubi8-minimal:8.2
USER 0
ENV HOME=/home/user

# NOTE: uncommented for local build.
# Must also set full registry path in FROM to registry.redhat.io or registry.access.redhat.com
# enable rhel 7 or 8 content sets (from Brew) to resolve jq and bash-completion as rpm
#@local COPY ./content_set*.repo /etc/yum.repos.d/

RUN mkdir /home/user && \
    microdnf install -y \
    # bash completion tools
    bash-completion ncurses pkgconf-pkg-config \
    # developer tools
    curl git procps \
    # is needed for install yq
    python2-pip python2-pip-wheel && \
    microdnf -y clean all && \
    # install yq
    pip2 install yq && \
    # # enable bash completion in interactive shells
    echo source /etc/profile.d/bash_completion.sh >> ~/.bashrc

COPY .container-root/opt/. /opt
COPY .container-root/usr/local/bin/. /usr/local/bin/
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
ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
