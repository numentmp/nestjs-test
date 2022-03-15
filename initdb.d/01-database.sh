#!/usr/bin/env bash

if [    -z "${BASH_VERSINFO[0]}" ] || \
   [ 4 -gt "${BASH_VERSINFO[0]}" ] || \
   [ 4 -eq "${BASH_VERSINFO[0]}" -a 4 -gt "${BASH_VERSINFO[1]}" ]
then
    printf '\e[91mERROR: Неизвестная или неподдерживаемая версия bash\e[0m\n' 1>&2
    printf '\e[93mЕсли используется Mac OS, установить актуальную версию bash\e[0m\n' 1>&2
    printf '\e[93m  brew install bash\e[0m\n' 1>&2
    printf '\e[93mи запускайте скрипт через через прямой вызов bash\e[0m\n' 1>&2
    printf '\e[93m  /usr/local/bin/bash %q\e[0m\n' "$0" 1>&2
    exit 1
fi

declare -g SCRIPT_DIR=`dirname "$0"`
cd "$SCRIPT_DIR" || exit 1
source common.sh_ || exit 1

declare -g APP_DB_USER="${APP_DB_USER-app}"
declare -g APP_DB_PASS="${APP_DB_PASS-password}"

generate()
{
  cat <<EOF
CREATE DATABASE ${APP_DB_NAME}
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE = utf8mb4_general_ci
;

CREATE USER ${APP_DB_USER}
  IDENTIFIED BY '${APP_DB_PASS}'
;

GRANT INSERT, SELECT, UPDATE, DELETE
  ON ${APP_DB_NAME}.*
  TO '${APP_DB_USER}'@'%'
;

USE $APP_DB_NAME;

CREATE TABLE table1 (
  id INT NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (id)
) ENGINE=InnoDB;
EOF
}

proc "$@"
