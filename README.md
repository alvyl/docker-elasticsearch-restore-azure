## docker-elasticsearch-restore-azure
A Docker container to restore Elasticsearch snapshots.

## Required Environment variables
- _`$BACKUP_REPOSITORY_NAME`_ - Name of the repository, where the snapshot is present. Refer to the  [repositories](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_repositories) section of the official elasticsearch docs.
- _`SNAPSHOT_NAME`_ - Name of the snapshot, from which the recovery is to be initiated.
- _`ELASTICSEARCH_HOST`_ - Host name of the machine running Elasticsearch
- _`ELASTICSEARCH_PORT`_ - Port number where Elasticsearch is running
- _`DEBUG`_ - If true will give you the value of all variables in terminal. default to false

**Special Note:** *No defaults are assumed. The script will return error if the required Environment variables are not passed.*

## Container startup explained

On running this container,
* A es restore HTTP request is made in accordance to the elasticsearch documentation, using the provided `_BACKUP_REPOSITORY_NAME_` and `_SNAPSHOT_NAME_`, for the given `_ELASTICSEARCH_HOST_`, `_ELASTICSEARCH_PORT_` values.

## Sample runs

**NOTE:** If the Elasticsearch server is also a docker image, make sure that you use the `--network=<network_name>` option while running the docker command.

#### With Debug enabled

```bash
docker run --rm --name es-restore [--network=XXX] \
-e "BACKUP_REPOSITORY_NAME=backup" \
-e "SNAPSHOT_NAME=snapshot_2" \
-e "ELASTICSEARCH_HOST=es-server" \
-e "ELASTICSEARCH_PORT=9200" \
-e "DEBUG=true" \
gvatreya/docker-elasticsearch-restore-azure

[DEBUG] BACKUP_REPOSITORY_NAME = backup
[DEBUG] SNAPSHOT_NAME = snapshot_2
[DEBUG] ELASTICSEARCH_HOST = es-server
[DEBUG] ELASTICSEARCH_PORT = 9200
 [INFO] Closing all indices to proceed with the restore.
[DEBUG] Result: {"acknowledged":true}
 [INFO] Initializing Snapshot recovery.
[DEBUG] Result: {"snapshot":{"snapshot":"snapshot_2","indices":["twitter"],"shards":{"total":5,"failed":0,"successful":5}}}
[INFO] Successfully recovered from snapshot. Exiting now
```

#### With Debug disabled

```bash
docker run --rm --name es-restore [--network=XXX] \
-e "BACKUP_REPOSITORY_NAME=backup" \
-e "SNAPSHOT_NAME=snapshot_2" \
-e "ELASTICSEARCH_HOST=es-server" \
-e "ELASTICSEARCH_PORT=9200" \
-e "DEBUG=false" \
gvatreya/docker-elasticsearch-restore-azure

[INFO] Debug not enabled. To enable, set DEBUG=true
[INFO] Closing all indices to proceed with the restore.
[INFO] Initializing Snapshot recovery.
[INFO] Successfully recovered from snapshot. Exiting now
```

#### Error - Unreachable host
```bash
docker run --rm --name es-restore [--network=XXX] \
-e "BACKUP_REPOSITORY_NAME=backup" \
-e "SNAPSHOT_NAME=snapshot_2" \
-e "ELASTICSEARCH_HOST=NON-EXISTING-HOST" \
-e "ELASTICSEARCH_PORT=9200" \
-e "DEBUG=true" \
gvatreya/docker-elasticsearch-restore-azure

[DEBUG] BACKUP_REPOSITORY_NAME = backup
[DEBUG] SNAPSHOT_NAME = snapshot_2
[DEBUG] ELASTICSEARCH_HOST = NON-EXISTING-HOST
[DEBUG] ELASTICSEARCH_PORT = 9200
[ERROR] Are you sure the supplied elasticsearch host and/or port (NON-EXISTING-HOST,9200) is correct ?
```

#### Error - Invalid snapshot name
```bash
docker run --rm --name es-restore [--network=XXX] \
-e "BACKUP_REPOSITORY_NAME=backup" \
-e "SNAPSHOT_NAME=INVALID_NAME" \
-e "ELASTICSEARCH_HOST=es-server" \
-e "ELASTICSEARCH_PORT=9200" \
-e "DEBUG=true" \
gvatreya/docker-elasticsearch-restore-azure

[DEBUG] BACKUP_REPOSITORY_NAME = backup
[DEBUG] SNAPSHOT_NAME = INVALID_NAME
[DEBUG] ELASTICSEARCH_HOST = es-server
[DEBUG] ELASTICSEARCH_PORT = 9200
 [INFO] Closing all indices to proceed with the restore.
[DEBUG] Result: {"acknowledged":true}
 [INFO] Initializing Snapshot recovery.
[DEBUG] Result: {"error":{"root_cause":[{"type":"snapshot_restore_exception","reason":"[backup:INVALID_NAME] snapshot does not exist"}],"type":"snapshot_restore_exception","reason":"[backup:INVALID_NAME] snapshot does not exist"},"status":500}
[ERROR] Error occurred while recovering from snapshot. Exiting now
```

## Building image
```bash
docker build -t gvatreya/docker-elasticsearch-restore-azure .
```
