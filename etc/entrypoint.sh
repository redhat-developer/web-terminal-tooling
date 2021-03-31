#!/bin/bash
set -e

# Ensure $HOME exists when starting
if [ ! -d "${HOME}" ]; then
  mkdir -p "${HOME}"
fi

# Setup $PS1 for a consistent and reasonable prompt
if [ -w "${INITIAL_CONFIG}" ] && [ -z "$PS1" ] && ! grep -q "PS1" "${INITIAL_CONFIG}/.bashrc"; then
  echo "PS1='\s-\v \w \$ '" >> "${INITIAL_CONFIG}/.bashrc"
fi

# Set default editor to vim instead of fallback vi
if [ -w "${INITIAL_CONFIG}" ] && ! grep -q "EDITOR" "${INITIAL_CONFIG}/.bashrc"; then
  echo "EDITOR=vim" >> "${INITIAL_CONFIG}/.bashrc"
fi

# Add current (arbitrary) user to /etc/passwd and /etc/group
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-user}:x:$(id -u):0:${USER_NAME:-user} user:${HOME}:/bin/bash" >> /etc/passwd
    echo "${USER_NAME:-user}:x:$(id -u):" >> /etc/group
  fi
fi

find "$INITIAL_CONFIG" -mindepth 1 -exec cp -nrp {} "${HOME}/" \;

exec "$@"
