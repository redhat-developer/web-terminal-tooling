#!/bin/sh
set -e

TOOL=${TOOL:-podman}
MODE=${MODE:-local}
WEB_TERMINAL_TOOLING_IMG=${WEB_TERMINAL_TOOLING_IMG:-web-terminal-tooling:local}

./download-dependencies.sh

cp template.Dockerfile complete.Dockerfile
sed -i "s/\#@${MODE} /#@${MODE}\n/" complete.Dockerfile

${TOOL} build -t ${WEB_TERMINAL_TOOLING_IMG} --file complete.Dockerfile .
