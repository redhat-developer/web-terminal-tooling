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
    .plugin.components= [{
      "name": "web-terminal-tooling",
      "container": {
        "image": $IMAGE
      }
    }]
  else . end
]
'

# Remove container image override for the web-terminal-tooling image in a
# DevWorkspace
export JQ_RESET_IMAGE_SCRIPT='
.spec.template.components = [.spec.template.components[] |
  if .name == "web-terminal-tooling"
  then
    del(.plugin.components)
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
    .plugin.components= [{
      "name": "web-terminal-exec",
      "container": {
        "env": [{
          "name": "WEB_TERMINAL_IDLE_TIMEOUT",
          "value": $TIMEOUT
        }]
      }
    }]
  else . end
]
'

# Delete WEB_TERMINAL_IDLE_TIMEOUT env var override in web-terminal-exec
# container on a DevWorkspace.
export JQ_RESET_TIMEOUT_SCRIPT='
.spec.template.components = [.spec.template.components[] |
  if .name == "web-terminal-exec"
  then
    del(.plugin.components)
  else . end
]
'
