# Datomic-pro

Datomic SQL docker image

- datomic-pro-1.0.7075
- postgres:12.19-alpine
- eclipse-temurin:22-jre-alpine

## Usage

`git clone https://github.com/guillerglez88/datomic-pro.git --depth=1`

`cd ./datomic-pro`

`docker compose up --build`

## Connect

- datomic-uri: `datomic:sql://<db-name>?jdbc:postgresql://localhost:5432/datomic?user=datomic&password=<pass>`
- datomic-console: `http://localhost:8080/browse`
- postgres: `jdbc:postgresql://localhost:5432/datomic?user=postgres&password=postgres`

```edn
{:deps {
  com.datomic/peer {:mvn/version "1.0.7075"}
  org.postgresql/postgresql {:mvn/version "42.7.3"}}}
```

```clojure
(require '[datomic.api :as d])

(d/create-database datomic-uri)

(d/connect datomic-uri)
```


## Restore backups

When the container is created, there is a script that checks for /backups/.restore-log under the `data` volume dir and creates it if doesn't exist. To restore datomic backups, you only need to drop a backup .zip file under /backups folder and restart the container. When the backup is successfully restored, the .zip file path is appended to /backups/.restore-log file e.g: `/app/data/backups/backup-1715945814.zip` so that the next time you restart de container it won't try to restore the backup. If you want to reset the storage, you should remove /pgdata dir under the `data` volume. If you need to restore a backup already added to /backups/.restore-log, only remove its line from this file.
