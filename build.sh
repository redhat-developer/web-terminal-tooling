#!/bin/bash
set -e

TOOL=${TOOL:-podman}
WEB_TERMINAL_TOOLING_IMG=${WEB_TERMINAL_TOOLING_IMG:-web-terminal-tooling:local}

USAGE="Usage: ./build.sh [OPTIONS]
Options:
    --help
        Print this message.
    --image, -i [TAG]
        Docker image to be used for image. Default: 'web-terminal-tooling:local'
    --docker
        Use docker instead of podman. Default: use podman
    --update-sources, -u
        Download dependencies tarball. Default: enabled only if container-root-x86_64.tgz is not present
"

function print_usage() {
    echo -e "$USAGE"
}

function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            '-i'|'--image')
            WEB_TERMINAL_TOOLING_IMG="$2"
            shift 1
            ;;
            '--docker')
            TOOL=docker
            shift 0
            ;;
            '-u'|'--update-sources')
            updateBinariesTgz="true"
            shift 0
            ;;
            '--help')
            print_usage
            exit 0
            ;;
            *)
            echo -e "Unknown option $1 is specified. See usage:\n"
            print_usage
            exit 0
        esac
        shift 1
    done
}

parse_arguments "$@"

if [[ ! -f "container-root-x86_64.tgz" ]] || [[ "$updateBinariesTgz" == "true" ]]; then
  echo "Updating locally cached sources tarball"
  ./get-sources.sh
fi

${TOOL} build -t "${WEB_TERMINAL_TOOLING_IMG}" --file ./Dockerfile .
