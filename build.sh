#!/bin/bash
set -e

updateBinariesTgz="false"
while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-u'|'--update-sources') updateBinariesTgz="true"; shift 0;;
  esac
  shift 1
done

TOOL=${TOOL:-podman}
MODE=${MODE:-local}
WEB_TERMINAL_TOOLING_IMG=${WEB_TERMINAL_TOOLING_IMG:-web-terminal-tooling:local}

if [[ ! -f "container-root.tgz" ]] || [[ "$updateBinariesTgz" == "true" ]]; then
  echo "Updating locally cached sources tarball"
  ./get-sources-jenkins.sh
fi

sed "s/\#@${MODE} /#@${MODE}\n/" template.Dockerfile > complete.Dockerfile

${TOOL} build -t "${WEB_TERMINAL_TOOLING_IMG}" --file complete.Dockerfile .
