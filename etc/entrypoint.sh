#!/bin/bash

set -e

# Ensure $HOME exists when starting
if [ ! -d "${HOME}" ]; then
  mkdir -p "${HOME}"
fi

# Add current (arbitrary) user to /etc/passwd and /etc/group
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-user}:x:$(id -u):0:${USER_NAME:-user} user:${HOME}:${SHELL}" >> /etc/passwd
    echo "${USER_NAME:-user}:x:$(id -u):" >> /etc/group
  fi
fi

# Copy files in $INITIAL_CONFIG to $HOME without overwriting existing files
find "$INITIAL_CONFIG" -mindepth 1 -exec cp -nrp {} "${HOME}/" \;

exec "$@"
