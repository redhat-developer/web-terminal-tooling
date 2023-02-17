#!/bin/bash
#
# Copyright (c) 2020-2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#

# Set container image override for the web-terminal-tooling image in a
# DevWorkspace. Expects argument $IMAGE to be the image to set.
# shellcheck disable=SC2016
export JQ_SET_IMAGE_SCRIPT='
.spec.template.components = [.spec.template.components[] |
  if .name == "web-terminal-tooling"
  then
    # Add overrides component if it is not present
    if .plugin.components | length == 0
    then
      .plugin.components = [{"name": "web-terminal-tooling"}]
    else . end
    |
    # Set image in container overrides
    .plugin.components[0].container.image = $IMAGE
  else . end
]
'

# Remove container image override for the web-terminal-tooling image in a
# DevWorkspace
export JQ_RESET_IMAGE_SCRIPT='
.spec.template.components = [.spec.template.components[] |
  if .name == "web-terminal-tooling"
  then
    # Remove image override from overrides
    del(.plugin.components[].container.image)
    |
    # If overrides section is now empty, remove it
    if .plugin.components[].container == {}
    then
      del(.plugin.components)
    else . end
  else . end
]
'

# Get current value of WEB_TERMINAL_IDLE_TIMEOUT env var from a PodList
export JQ_GET_TIMEOUT_SCRIPT='
.items[0].spec.containers[] |
  select(.name == "web-terminal-exec") |
  .env[] |
  select(.name == "WEB_TERMINAL_IDLE_TIMEOUT") |
  .value
'

# Set WEB_TERMINAL_IDLE_TIMEOUT env var in web-terminal-exec container on a
# DevWorkspace. Expects argument $TIMEOUT to be the timeout to set
export JQ_SET_TIMEOUT_SCRIPT='
.spec.template.components = [.spec.template.components[] |
  if .name == "web-terminal-exec"
  then
    # If overrides section is empty, add entry to avoid error below
    if .plugin.components | length == 0
    then
      .plugin.components = [{"name": "web-terminal-exec"}]
    else . end
    |
    # If a value is already set, update it. Otherwise, add new env var with specified value
    if (.plugin.components[].container.env | length > 0)
        and any(.plugin.components[].container.env[]; .name == "WEB_TERMINAL_IDLE_TIMEOUT")
    then
      .plugin.components[0].container.env |=
        map(if .name == "WEB_TERMINAL_IDLE_TIMEOUT" then .value = $TIMEOUT else . end)
    else
      .plugin.components[0].container.env += [{
        "name": "WEB_TERMINAL_IDLE_TIMEOUT",
        "value": $TIMEOUT
      }]
    end
  else . end
]
'

# Delete WEB_TERMINAL_IDLE_TIMEOUT env var override in web-terminal-exec
# container on a DevWorkspace.
export JQ_RESET_TIMEOUT_SCRIPT='
.spec.template.components = [.spec.template.components[] |
  if .name == "web-terminal-exec"
  then
    # Add component to avoid iterate over null error
    if .plugin.components | length == 0
    then
      .plugin.components = [{"name": "web-terminal-exec"}]
    else . end
    |
    # Remove idle timeout env var from overrides list, preserving existing entries if present
    if (.plugin.components[].container.env | length > 0) and
        any(.plugin.components[].container.env[]; .name == "WEB_TERMINAL_IDLE_TIMEOUT")
    then
      .plugin.components[].container.env -= [.plugin.components[].container.env[]
      |
      select(.name == "WEB_TERMINAL_IDLE_TIMEOUT")]
      |
      # If env list is now empty, delete the field
      if .plugin.components[].container.env | length == 0
      then
        del(.plugin.components[].container.env)
      else . end
    else . end
    |
    # If overrides section is empty, remove it entirely
    if .plugin.components[].container == {}
    then
      del(.plugin.components)
    else . end
  else . end
]
'
