#!/bin/bash

set -euo pipefail;

export SING_PREFIX_ISG_4_2_7_IMAGE="/software/isg/private/experimental/irods/4.2.7/lib/4.2.7_239104_main.sif"
export IRODS_ENVIRONMENT_FILE=~/.irods/irods_environment.humgen.json;

declare LAST="$(/software/isg/private/experimental/irods/4.2.7/bin/iquest "SELECT max(DATA_MODIFY_TIME) WHERE META_DATA_ATTR_NAME = 'ibackup:fofn:set'" | head -n1 | cut -d'=' -f2 | tr -d ' ' | sed -e 's/^0*//')";

if [ "$(date -d "8 days ago" +%s)" -gt "$LAST" ]; then
	echo -n "Last Backup-Plans backup was at: ";
	date -d @$LAST;

	exit 1;
fi;
