#!/bin/bash

_restore() {

  # The repository that is registered for the backup.
  # To list the repositories available and their details
  # curl -X GET "localhost:9200/_snapshot"
  export BACKUP_REPOSITORY_NAME={{BACKUP_REPOSITORY_NAME}}

  # The name of the snapshot to be used for the restore
  # To list all the repositories in the backup repository use the following command
  # curl -XGET "localhost:9200/_snapshot/BACKUP_REPOSITORY_NAME/_all"
  export SNAPSHOT_NAME={{SNAPSHOT_NAME}}

  # Host and port where elasticsearch is running
  export ELASTICSEARCH_HOST={{ELASTICSEARCH_HOST}}
  export ELASTICSEARCH_PORT={{ELASTICSEARCH_PORT}}

  export DEBUG={{DEBUG}}

  if [[ "$DEBUG" == "true" ]]; then
    echo "[DEBUG] BACKUP_REPOSITORY_NAME = $BACKUP_REPOSITORY_NAME"
    echo "[DEBUG] SNAPSHOT_NAME = $SNAPSHOT_NAME"
    echo "[DEBUG] ELASTICSEARCH_HOST = $ELASTICSEARCH_HOST"
    echo "[DEBUG] ELASTICSEARCH_PORT = $ELASTICSEARCH_PORT"
  else
    echo " [INFO] Debug not enabled. To enable, set DEBUG=true"
  fi

  # Check if host and port combination works
  curl -XGET --silent --output /dev/null $ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT
  curl_output=$?
  if [[ "$curl_output" != 0 ]]; then
    echo "[ERROR] Are you sure the supplied elasticsearch host and/or port ($ELASTICSEARCH_HOST,$ELASTICSEARCH_PORT) is correct ?"
    exit -1
  fi

  echo " [INFO] Closing all indices to proceed with the restore."
  # Need to close all the indices before restoring snapshot
  close_result=$(curl -XPOST --silent $ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_all/_close)

  if [[ "$DEBUG" == "true" ]]; then
    echo "[DEBUG] Result: $close_result"
  fi

  close_result=$(echo $close_result | jq -r '.acknowledged')

  if [[ "$close_result" != "true" ]]; then
    echo "[ERROR] Unable to close indices. Please check and re-run. Exiting now."
    exit -1
  fi

  echo " [INFO] Initializing Snapshot recovery."
  # Initialize the recovery of the snapshot
  # The output of the below command should be like below
  #   {
  #   "snapshot": {
  #     "snapshot": "snapshot_2",
  #     "indices": [
  #       "index_1"
  #     ],
  #     "shards": {
  #       "total": 5,
  #       "failed": 0,
  #       "successful": 5
  #     }
  #   }
  # }
  restore_result=$(curl -XPOST --silent $ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_snapshot/$BACKUP_REPOSITORY_NAME/$SNAPSHOT_NAME/_restore?wait_for_completion=true)

  if [[ "$DEBUG" == "true" ]]; then
    echo "[DEBUG] Result: $restore_result"
  fi

  total_count=$(echo $restore_result | jq -r '.snapshot.shards.total')
  successful_count=$(echo $restore_result | jq -r '.snapshot.shards.successful')

  if [[ -z $total_count ]] && [[ -z $successful_count ]] && [[ $total_count == $successful_count ]]; then
    echo " [INFO] Successfully recovered from snapshot. Exiting now"
    exit 0
  else
    echo "[ERROR] Error occurred while recovering from snapshot. Exiting now"
  fi

}

_restore;
