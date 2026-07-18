#!/bin/bash

set -euo pipefail;

module load ISG/IRODS;

export IRODS_ENVIRONMENT_FILE=~/.irods/irods_environment.humgen.json;

declare LAST="$(iquest "SELECT max(DATA_MODIFY_TIME) WHERE META_DATA_ATTR_NAME = 'ibackup:fofn:set'" | head -n1 | cut -d'=' -f2 | tr -d ' ' | sed -e 's/^0*//')";

if [ "$(date -d "8 days ago" +%s)" -gt "$LAST" ]; then
	echo -n "Last Backup-Plans backup was at: ";
	date -d @$LAST;

	exit 1;
fi;
