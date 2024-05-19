FROM eclipse-temurin:22-jre-alpine as base
WORKDIR /app
ARG VERSION
RUN apk update && apk add curl
RUN curl https://datomic-pro-downloads.s3.amazonaws.com/${VERSION}/datomic-pro-${VERSION}.zip -O
RUN unzip datomic-pro-${VERSION}.zip
RUN mv ./datomic-pro-${VERSION} ./datomic-pro
COPY transactor.properties ./datomic-pro/config/transactor.properties
COPY restore-backup.sh .
RUN chmod +x ./restore-backup.sh

FROM postgres:12.19-alpine as prod
WORKDIR /app
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV POSTGRES_DB=datomic
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV DATOMIC_STORAGE_ADMIN_PASSWORD=admin
ENV DATOMIC_STORAGE_DATOMIC_PASSWORD=datomic
COPY --from=base $JAVA_HOME $JAVA_HOME
COPY --from=base /app/datomic-pro .
COPY --from=base /app/datomic-pro/bin/sql/postgres-table.sql /docker-entrypoint-initdb.d/
COPY --from=base /app/datomic-pro/bin/sql/postgres-user.sql /docker-entrypoint-initdb.d/
COPY --from=base /app/restore-backup.sh .
VOLUME ["/app/data"]
EXPOSE 4334
EXPOSE 4335
EXPOSE 5432
EXPOSE 8080
ENTRYPOINT exec \
    && echo "sql-url=jdbc:postgresql://localhost:5432/$POSTGRES_DB" >> ./config/transactor.properties \
    && echo "sql-user=$POSTGRES_USER" >> ./config/transactor.properties \
    && echo "sql-password=$POSTGRES_PASSWORD" >> ./config/transactor.properties \
    && echo "storage-admin-password=$DATOMIC_STORAGE_ADMIN_PASSWORD" >> ./config/transactor.properties \
    && echo "storage-datomic-password=$DATOMIC_STORAGE_DATOMIC_PASSWORD" >> ./config/transactor.properties \
    && docker-entrypoint.sh -c 'shared_buffers=2GB' \
    & ./bin/transactor config/transactor.properties \
    & ./restore-backup.sh \
    & ./bin/console -p 8080 sql datomic:sql://?jdbc:postgresql://localhost:5432/$POSTGRES_DB?user=datomic\&password=$DATOMIC_STORAGE_DATOMIC_PASSWORD
