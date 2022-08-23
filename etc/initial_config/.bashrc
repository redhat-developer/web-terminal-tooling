# Set default editor to vim instead of default fallback vi
EDITOR=vim

function help_message() {
  source /tmp/tooling_versions.env
  # Kubectl version isn't explicitly defined and instead matches oc version
  KUBECTL_VER=$(kubectl version --client --short 2>/dev/null | grep 'Client Version' | sed 's|Client Version: ||')
  JQ_VER=$(jq --version)
  JQ_VER=${JQ_VER#jq-}

  echo "Installed tools:"
  cat <<EOF | column -t -s '|'
Command  |Version  |Name
oc|$OC_VER|OpenShift CLI
kubectl|$KUBECTL_VER|Kubernetes CLI
helm|$HELM_VER|Helm CLI
kn|$KN_VER|KNative CLI
tkn|$TKN_VER|Tekton CLI
subctl|$SUBMARINER_VERSION|Submariner CLI
odo|$ODO_VER|Red Hat OpenShift Developer CLI
rhoas|$RHOAS_VERSION|Red Hat OpenShift Application Services CLI
virtctl|$KUBEVIRT_VERSION|KubeVirt CLI
jq|$JQ_VER|jq
EOF
  echo ""
  echo "To customize this terminal, see 'wtoctl'"
}

alias help=help_message

complete -C /usr/local/bin/odo odo
source /etc/profile.d/bash_completion.sh

# Since xterm doesn't save history on exit, we manually sync history on each command
shopt -s histappend
# Append lines from this session to history, clear the session's history, re-read the history file
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

echo 'Welcome to the OpenShift Web Terminal. Type "help" for a list of installed CLI tools.'
