#!/bin/bash

# config datomic
echo "sql-url=jdbc:postgresql://localhost:5432/$POSTGRES_DB" >> ./config/transactor.properties
echo "sql-user=$POSTGRES_USER" >> ./config/transactor.properties
echo "sql-password=$POSTGRES_PASSWORD" >> ./config/transactor.properties
echo "storage-admin-password=$DATOMIC_STORAGE_ADMIN_PASSWORD" >> ./config/transactor.properties
echo "storage-datomic-password=$DATOMIC_STORAGE_DATOMIC_PASSWORD" >> ./config/transactor.properties

# start postgres entrypoint
docker-entrypoint.sh -c 'shared_buffers=2GB' &

# start datomic transactor
./bin/transactor config/transactor.properties &

# restore datomic backups
./restore-backup.sh &

# start datomic console
./bin/console -p 8080 pro datomic:sql://?jdbc:postgresql://localhost:5432/$POSTGRES_DB?user=datomic\&password=$DATOMIC_STORAGE_DATOMIC_PASSWORD
