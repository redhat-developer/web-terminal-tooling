#!/bin/bash

set -e

SCRIPT_DIR=${PROJECT_ROOT:-$(cd "$(dirname "$0")" || exit; pwd)}

BREW_BUILD_MODE="brew"
LOCAL_BUILD_MODE="local"

outputFilename="complete.Dockerfile"
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
  sed -E -e 's/^#@Brew ?//' \
         -e '/^#@local/d' \
         "${SCRIPT_DIR}/template.Dockerfile" \
         > "${SCRIPT_DIR}/../${outputFilename}"
  ;;
  $LOCAL_BUILD_MODE)
  sed -E -e 's/^#@local ?//' \
         -e '/^#@Brew/d' \
         "${SCRIPT_DIR}/template.Dockerfile" \
         > "${SCRIPT_DIR}/../${outputFilename}"
  ;;
esac