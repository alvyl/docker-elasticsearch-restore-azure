#!/bin/bash

sed 's,{{BACKUP_REPOSITORY_NAME}},'"${BACKUP_REPOSITORY_NAME}"',g' -i /restore/restore.sh
sed 's,{{SNAPSHOT_NAME}},'"${SNAPSHOT_NAME}"',g' -i /restore/restore.sh
sed 's,{{ELASTICSEARCH_PORT}},'"${ELASTICSEARCH_PORT}"',g' -i /restore/restore.sh
sed 's,{{ELASTICSEARCH_HOST}},'"${ELASTICSEARCH_HOST}"',g' -i /restore/restore.sh
sed 's,{{DEBUG}},'"${DEBUG}"',g' -i /restore/restore.sh

. /restore/restore.sh;
exit 0
