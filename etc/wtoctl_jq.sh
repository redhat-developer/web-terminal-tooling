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

# Set environment variable in a container on a DevWorkspace. Expects arguments:
#   - $COMPONENT : name of component (used for container name as well)
#   - $NAME      : name of env var to set
#   - $VALUE     : value for env var to set
export JQ_SET_ENV_SCRIPT='
.spec.template.components = [.spec.template.components[] |
  if .name == $COMPONENT
  then
    # If overrides section is empty, add entry to avoid error below
    if .plugin.components | length == 0
    then
      .plugin.components = [{"name": $COMPONENT}]
    else . end
    |
    # If a value is already set, update it. Otherwise, add new env var with specified value
    if (.plugin.components[].container.env | length > 0)
        and any(.plugin.components[].container.env[]; .name == $NAME)
    then
      .plugin.components[0].container.env |=
        map(if .name == $NAME then .value = $VALUE else . end)
    else
      .plugin.components[0].container.env += [{
        "name": $NAME,
        "value": $VALUE
      }]
    end
  else . end
]
'

# Delete environment variable override in container on a DevWorkspace. Expects arguments:
#   - $COMPONENT : name of component (used for container name as well)
#   - $NAME      : name of env var to set
export JQ_RESET_ENV_SCRIPT='
.spec.template.components = [.spec.template.components[] |
  if .name == $COMPONENT
  then
    # Add component to avoid iterate over null error
    if .plugin.components | length == 0
    then
      .plugin.components = [{"name": $COMPONENT}]
    else . end
    |
    # Remove idle timeout env var from overrides list, preserving existing entries if present
    if (.plugin.components[].container.env | length > 0) and
        any(.plugin.components[].container.env[]; .name == $NAME)
    then
      .plugin.components[].container.env -= [.plugin.components[].container.env[]
      |
      select(.name == $NAME)]
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
