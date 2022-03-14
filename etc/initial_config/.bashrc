# Set default editor to vim instead of default fallback vi
EDITOR=vim

INSTALLED_TOOLS='Command\tVersion\tName
oc $OC_VER
kubectl $KUBECTL_VER
helm $HELM_VER
kn (KNative CLI) $KN_VER
tkn (Tekton CLI) $TKN_VER
subctl (Submariner CLI) $SUBMARINER_VERSION
odo (Red Hat OpenShift Developer CLI) $ODO_VER
rhoas (Red Hat OpenShift Application Services CLI) $RHOAS_VERSION
kubectx & kubens $KUBECTX_VERSION
jq $JQ_VER
'

function help_message() {
  source /tmp/tooling_versions.env
  # Kubectl version isn't explicitly defined and instead matches oc version
  KUBECTL_VER=$(kubectl version --client --short | sed 's|Client Version: ||')
  JQ_VER=$(jq --version)
  JQ_VER=${JQ_VER#jq-}

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
kubectx|$KUBECTX_VERSION|Kubernetes Context CLI
kubens|$KUBECTX_VERSION|Kubernetes Namespace CLI
jq|$JQ_VER|jq
EOF
}

alias help=help_message

complete -C /usr/local/bin/odo odo
source /etc/profile.d/bash_completion.sh

echo 'Welcome to the OpenShift Web Terminal. Type "help" for a list of installed CLI tools.'
