#!/bin/sh
##
#
#   hc-db-setup.sh
#
#   (c) 2021 Granicus. All rights reserved.
#
#   Initial database config for Host Compliance local development
#
##

set -e
set -u
#set -x

createrole() { createuser --no-login "$@"; }

setpassword() {
	user=$1
	password=$2

	cat <<-EOF | psql
		ALTER USER ${user}
		WITH ENCRYPTED PASSWORD '${password}'
		VALID UNTIL 'infinity'
		;
	EOF
}


BIN="$1"
DATADIR="$2"

TZ=UTC "${BIN}/initdb" --username=postgres --locale=en_US.UTF-8 --encoding="UTF-8" "${DATADIR}"

TZ=UTC "${BIN}/postgres" -D "${DATADIR}" & #>/dev/null 2>&1 &
server_pid=$!

sleep 5

PGUSER=postgres
export PGUSER

createuser --superuser --createdb --createrole --replication "${USER}"
createdb --username "${USER}" "${USER}"

createrole readaccess
createrole 'readonly'
createrole rds_ad
createrole rds_iam
createrole rds_password
createrole rds_replication
createrole \
	--role=pg_monitor \
	--role=pg_signal_backend \
	--role=rds_password \
	--role=rds_replication \
	rds_superuser

createuser --createdb --createrole --role=rds_superuser vrapi

createuser --createdb --createrole --role=rds_superuser vrapi_local

createuser --role=vrapi application_466611
createuser --role=rds_superuser --role=vrapi pgexpert
createuser --role=readaccess klipfolio
createuser --role=readaccess sales
createuser --role=readaccess zapier_887512
createuser --role='readonly' ro
createuser vrapi_ro
createuser hasurauser
createuser strhelper
createuser datafoundry
createuser csuser
createuser datadog
createuser avuser

createdb --owner=vrapi vrapi
createdb --owner=vrapi_local vrapi_local

kill "${server_pid}"
wait "${server_pid}"


# vi: set tw=80 ts=4 sw=4 noet:
