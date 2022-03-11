#!/bin/bash

function general_help() {
  cat <<EOF
wtoctl is a simple tool for customizing Web Terminals in OpenShift intended to
be used within a running terminal instance.

Configurable fields:
  * image   - the image used for the terminal
  * timeout - the time a Web Terminal may be idle before it is terminated

Available commands:
  * get   - get the current value for a field
  * set   - set the current value for a field
  * reset - reset a field to its default value

Usage:
  wtoctl <command> [options]

Use wtoctl <command> --help for more information about a given command.
Use wtoctl <field> --help for more information about a given field.

To reset all changes and return to a default terminal, execute
  oc delete devworkspace $DEVWORKSPACE_NAME --namespace $NAMESPACE
and restart the Web Terminal
EOF
}

function image_help() {
  cat <<EOF
The image field defines which container image is used to run the Web Terminal.
By default, an image containing common cluster tooling is used, but this can be
extended or replaced with a custom built image to include additional tools or
configuration.

It is recommended to extend the default image (see 'wtoctl get image') when
building a custom tooling image to ensure configuration is correct.

If a misconfigured image is used, the Web Terminal may fail to restart. If this
occurs, the Web Terminal custom resource should be deleted by executing
  oc delete devworkspace $DEVWORKSPACE_NAME --namespace $NAMESPACE
EOF
}

function timeout_help() {
  cat <<EOF
The timeout field defines how long a Web Terminal should wait before shutting
down when left idle. The duration should be specified as a number and unit
suffix. Valid suffixes are "ms" (milliseconds), "s" (seconds), "m" (minutes),
and "h" (hours). After the specified duration, the web terminal will shut down
and need to be restarted the the next time it is accessed.

It is not recommended to use very long durations for this value, as it will
result in idle Web Terminals running for a long time.

Examples:
  * 15m   - 15 minutes
  * 1h30m - 1 hour and 30 minutes
  * 1.5h  - 1 hour and 30 minutes
EOF
}

function get_help() {
  cat <<EOF
Gets the current value of a field

Configurable fields:
  * image   - the image used for the terminal
  * timeout - the time a Web Terminal may be idle before it is terminated

Usage:
  wtoctl get <field>

Use wtoctl <field> --help for more information about a given field.
EOF
}

function set_help() {
  cat <<EOF
Sets a given field

Configurable fields:
  * image   - the image used for the terminal
  * timeout - the time a Web Terminal may be idle before it is terminated

Usage:
  wtoctl set <field> <value>

Use wtoctl <field> --help for more information about a given field.
EOF
}

function reset_help() {
  cat <<EOF
Resets a given field to its default value

Configurable fields:
  * image   - the image used for the terminal
  * timeout - the time a Web Terminal may be idle before it is terminated

Usage:
  wtoctl reset <field>

Use wtoctl <field> --help for more information about a given field.
EOF
}

function expect_no_args() {
  CMD_REF="$1"; shift
  if [[ $# -gt 0 ]]; then
    echo "Unknown option '$*' for '$CMD_REF'"
    echo "See '$CMD_REF --help' for usage"
    exit 1
  fi
}

function expect_one_arg() {
  CMD_REF="$1"; shift
  if [[ $# -eq 0 ]]; then
    echo "Command '$CMD_REF' expects an argument"
    echo "See '$CMD_REF --help' for usage."
    exit 1
  fi
  if [[ $# -gt 1 ]]; then
    echo "Command '$CMD_REF' expect only one argument"
    echo "See '$CMD_REF --help' for usage."
  fi
}

function help_or_error() {
  local HELP_CMD="$1"; shift
  local CMD_REF="$1"; shift
  if [[ $# -eq 0 ]]; then $HELP_CMD; exit 0; fi
  case $1 in
    "--help"|"help")
      $HELP_CMD ;;
    *)
      echo "Unknown option '$1' for '$CMD_REF'"
      echo "See '$CMD_REF --help' for usage"
      exit 1
  esac
}
