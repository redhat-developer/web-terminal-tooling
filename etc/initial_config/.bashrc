# Set default editor to vim instead of default fallback vi
EDITOR=vim

function help_message() {
  echo "Installed tools:"
  cat /tmp/installed_tools.txt
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
