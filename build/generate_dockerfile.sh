#!/bin/bash
#
# This script is used to generate different Dockerfiles from a template stored at
# template.Dockerfile. This is done by replacing or deleting lines based on a chosen
# build mode (e.g. "brew", "local"). To convert the template for e.g. the "brew" mode,
# all lines prefixed with #@brew are uncommented, and all lines prefixed with #@local
# are deleted, providing a valid Dockerfile that can be used within the Brew build system.
#
# The purposes of the different build modes are:
#   brew:        Dockerfile is meant for use within the brew build system and references resources
#                that are locally available there.
#   local:       Dockerfile is meant for a public build and references no non-public resources.
#
# Within the template, untagged lines are common to all Dockerfiles. The tags @brew, and @local
# are used to restrict a particular line to a specific build mode.
#

set -e

SCRIPT_DIR=${PROJECT_ROOT:-$(cd "$(dirname "$0")" || exit; pwd)}

BREW_BUILD_MODE="brew"
LOCAL_BUILD_MODE="local"

outputFilename="./build/complete.Dockerfile"
dockerfileMode="local"

function set_mode() {
  local mode=$1
  case $mode in
    'local') export dockerfileMode=${LOCAL_BUILD_MODE};;
    'brew') export dockerfileMode=${BREW_BUILD_MODE};;
    *) echo "Unrecognized build mode: $mode"; exit 1;;
  esac
}

if [ -n "$BUILD_MODE" ]; then
  set_mode "$BUILD_MODE"
fi

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-o'|'--output') outputFilename="$2"; shift 1;;
    '-m'|'--mode') set_mode "$2"; shift 1;;
  esac
  shift 1
done

echo "Creating dockerfile named $outputFilename for building in $dockerfileMode"

case $dockerfileMode in
  $BREW_BUILD_MODE)
  sed -E -e 's/^#@brew ?//' \
         -e '/^#@local/d' \
         "${SCRIPT_DIR}/template.Dockerfile" \
         > "${SCRIPT_DIR}/../${outputFilename}"
  ;;
  $LOCAL_BUILD_MODE)
  sed -E -e 's/^#@local ?//' \
         -e '/^#@brew/d' \
         "${SCRIPT_DIR}/template.Dockerfile" \
         > "${SCRIPT_DIR}/../${outputFilename}"
  ;;
esac
