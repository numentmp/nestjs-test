#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

declare -g DEF_MODE='run'
declare -g DEF_WARN=false

if [ "$#" == 0 ] && [ -z "${MYSQL_ROOT_PASSWORD+exists}" ]; then
  DEF_MODE='sql'
  DEF_WARN=true
fi

declare -g MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD-password}"
declare -g APP_DB_NAME="${APP_DB_NAME-app}"

print_error()
{
  printf '\e[91mERROR: %s\e[0m\n' "$1" 1>&2
}

print_warning()
{
  printf '\e[93mWARNING: %s\e[0m\n' "$1" 1>&2
}

proc()
{
  local MODE="${1-$DEF_MODE}"

  if [ x"$MODE" == x'run' ]; then
    if ! which mysql > /dev/null 2>&1; then
      print_error 'mysql cli not found'
      exit 1
    fi

    generate | mysql --user=root --password="$MYSQL_ROOT_PASSWORD"
  elif [ x"$MODE" == x'sql' ]; then
    generate
  elif [ x"$MODE" == x'cmd' ]; then
    printf 'mysql --user=root --password=%q <<"EOF"\n' "$MYSQL_ROOT_PASSWORD"
    generate
    echo EOF
  else
    print_error "Unknown mode '$MODE'"
    exit 1
  fi

  if $DEF_WARN; then
    print_warning "Available modes: run (default), cmd, sql."
    print_warning "No MYSQL_ROOT_PASSWORD env. Executed in '$DEF_MODE' mode."
    exit 1
  fi
}
