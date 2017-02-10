#!/bin/bash
#Created by Sam Gleske
#Thu Feb  9 20:11:11 PST 2017
#Ubuntu 16.04.1 LTS
#Linux 4.4.0-62-generic x86_64
#GNU bash, version 4.3.46(1)-release (x86_64-pc-linux-gnu)
#mysql  Ver 14.14 Distrib 5.7.17, for Linux (x86_64) using  EditLine wrapper
#https://github.com/samrocketman/example-mysql-live-migration

set -o errexit
set -o nounset
set -o pipefail

#
# DEFAULT ENV VARS
# see bash Parameter Expansion
#

#source database information
SRC_DB_HOST="${SRC_DB_HOST:-127.0.0.1}"
SRC_DB_PORT="${SRC_DB_PORT:-3333}"
SRC_DB_USER="${SRC_DB_USER:-datasync}"
SRC_DB_PASSWORD="${SRC_DB_PASSWORD:-syncpw}"
SRC_DB_DATABASE="${SRC_DB_DATABASE:-employees}"

#destination database information
DST_DB_HOST="${DST_DB_HOST:-127.0.0.1}"
DST_DB_PORT="${DST_DB_PORT:-3334}"
DST_DB_USER="${DST_DB_USER:-datasync}"
DST_DB_PASSWORD="${DST_DB_PASSWORD:-syncpw}"

#export the env vars (see bash Brace Expansion)
export {SRC,DST}_DB_{HOST,PORT,USER,PASSWORD} SRC_DB_DATABASE

#
# FUNCIONS
#
#output an error if a bad migration
function on_migration() {
  errcode=${1:-$?}
  echo ""
  if [ "${errcode}" = 0 ]; then
    echo "Migration of ${SRC_DB_DATABASE} to ${DST_DB_HOST}:${DST_DB_PORT} successful." 1>&2
  else
    env | grep 'DST_DB_\|SRC_DB_' | grep -v '_DB_PASSWORD'
    echo "Error: migration exited with error code: ${errcode}" 1>&2
  fi
  exit ${errcode}
}

#drop destination database if it exists
function dropExistingDestinationDB() {
  mysql -v \
    -h "${DST_DB_HOST}" -P "${DST_DB_PORT}" \
    -u "${DST_DB_USER}" "-p${DST_DB_PASSWORD}" <<EOF
DROP DATABASE IF EXISTS ${SRC_DB_DATABASE};
EOF
}

#dump database
function dumpSourceDB() {
  #outputs a database dump to stdout
  mysqldump \
    -h "${SRC_DB_HOST}" -P "${SRC_DB_PORT}" \
    -u "${SRC_DB_USER}" "-p${SRC_DB_PASSWORD}" \
    --single-transaction \
    --skip-extended-insert \
    --create-options \
    --databases "${SRC_DB_DATABASE}"
}

function importToDestinationDB() {
  #in bash the first command to read on stdin reads stdin for the function
  mysql -v \
    -h ${DST_DB_HOST} -P ${DST_DB_PORT} \
    -u ${DST_DB_USER} -p${DST_DB_PASSWORD}
}

#
# MIGRATION
#

#alert on errors
trap "on_migration" ERR
#catch keyboard interrupt ctrl+c
trap "on_migration 130" SIGINT

#perform migration
dropExistingDestinationDB
#output from the mysqldump is used as input to import via mysql
dumpSourceDB | importToDestinationDB

#congratulate on success
on_migration 0
