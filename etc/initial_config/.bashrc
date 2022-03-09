# Set default editor to vim instead of default fallback vi
EDITOR=vim

function help_message() {
  source /tmp/tooling_versions.env
  # Kubectl version isn't explicitly defined and instead matches oc version
  KUBECTL_VER=$(kubectl version --client --short | sed 's|Client Version: ||')
  cat <<EOF
Installed tooling:
  * jq
  * oc $OC_VER
  * kubectl $KUBECTL_VER
  * odo $ODO_VER
  * helm $HELM_VER
  * KNative $KN_VER
  * Tekton CLI $TKN_VER
  * kubectx & kubens $KUBECTX_VERSION
  * rhoas $RHOAS_VERSION
  * submariner $SUBMARINER_VERSION
EOF
}

alias help=help_message

complete -C /usr/local/bin/odo odo
source /etc/profile.d/bash_completion.sh

echo 'Welcome to the OpenShift Web Terminal. Type "help" for a list of installed CLI tools.'
