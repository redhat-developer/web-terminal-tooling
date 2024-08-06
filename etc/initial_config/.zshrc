# Set default editor to vim instead of default fallback vi
export EDITOR=vim

function help_message() {
  echo "Installed tools:"
  cat /tmp/installed_tools.txt
  echo ""
  echo "To customize this terminal, see 'wtoctl'"
}

alias help=help_message

# Set up saving history and syncing between sessions
setopt SHARE_HISTORY HIST_IGNORE_DUPS
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
bindkey -e

zstyle :compinstall filename '/home/user/.zshrc'
autoload -Uz compinit
compinit

# Source completions
if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh)
fi
if command -v kn &>/dev/null; then
  source <(kn completion zsh)
fi
if command -v helm &>/dev/null; then
  source <(helm completion zsh 2>/dev/null) # Needed to avoid warning about kubeconfig being world-writable
fi
if command -v tkn &>/dev/null; then
  source <(tkn completion zsh)
fi
if command -v virtctl &>/dev/null; then
  source <(virtctl completion zsh)
fi
if command -v rhoas &>/dev/null; then
  source <(rhoas completion zsh)
fi
if command -v subctl &>/dev/null; then
  source <(subctl completion zsh)
fi
if command -v odo &>/dev/null; then
  source <(odo completion zsh)
fi

PROMPT='%1N %~ %# '

echo 'Welcome to the OpenShift Web Terminal. Type "help" for a list of installed CLI tools.'
