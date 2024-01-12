#!/bin/bash
#
# Copyright (c) 2020-2024 Red Hat, Inc.
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

# Return the size of configured volume for a terminal, or empty sting if storage
# is not configured.
export JQ_GET_STORAGE_SIZE_SCRIPT='
if any(.spec.template.components[]; .name == "web-terminal-storage")
then
  .spec.template.components[] | select(.name == "web-terminal-storage") | .volume.size
else
  ""
end
'

# Return a line summarizing the current persistent storage configuration for the terminal
export JQ_GET_STORAGE_SCRIPT='
if any(.spec.template.components[]; .name == "web-terminal-storage")
then
  (.spec.template.components[] | select(.name == "web-terminal-storage") | .volume.size) as $volume_size |
  (.spec.template.components[] | select(.name == "web-terminal-tooling") | .plugin.components[0].container.volumeMounts[] | select(.name == "web-terminal-storage") | .path) as $mount_path |
  "Persistent storage (\($volume_size)) is mounted to \($mount_path)"
else
  "Persistent storage is not configured"
end
'

# Add volume and volume mount to web-terminal-tooling container in terminal. Expects arguments:
#   - $VOLUME_SIZE : size of volume component
#   - $MOUNT_PATH  : mount path for volume component
export JQ_SET_STORAGE_SCRIPT='
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
    .plugin.components[0].container.volumeMounts = [
      {
        "name": "web-terminal-storage",
        "path": $MOUNT_PATH
      }
    ]
  elif .name == "web-terminal-storage"
  then # Update volume if it already exists; this change may not be picked up
    .volume.size = $VOLUME_SIZE
  else . end
]
|
if any(.spec.template.components[]; .name == "web-terminal-storage")
then
  # Volume component already exists, avoid adding a second one
  .
else
  .spec.template.components += [
    {
      "name": "web-terminal-storage",
      "volume": {
        "size": $VOLUME_SIZE
      }
    }
  ]
end
|
.spec.template.attributes."controller.devfile.io/storage-type" = "per-workspace"
'

# Remove any persistent storage from workspace
export JQ_RESET_STORAGE_SCRIPT='
# Filter out volume compoennt
.spec.template.components = [.spec.template.components[] | select(.name == "web-terminal-storage" | not)]
|
# Remove volume mounts from container
.spec.template.components = [.spec.template.components[] |
  if .name == "web-terminal-tooling"
  then
    del(.plugin.components[0].container.volumeMounts)
  else . end
]
|
# Remove per-workspace storage type attribute
del(.spec.template.attributes."controller.devfile.io/storage-type") |
if (.spec.template.attributes | length) == 0
then
  del(.spec.template.attributes)
else . end
'

# Get the name of the PVC that is used for this workspace's storage. Expects argument
#   - $DEVWORKSPACE_NAME : name of the terminal's DevWorkspace
export JQ_GET_PVC_NAME_SCRIPT='.items[]
| select((.metadata.ownerReferences | length) > 0)
| select(any(.metadata.ownerReferences[]; .controller == true and .kind == "DevWorkspace" and .name == $DEVWORKSPACE_NAME))
| .metadata.name'
