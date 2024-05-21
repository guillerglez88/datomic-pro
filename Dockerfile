FROM eclipse-temurin:22-jre-alpine as base
WORKDIR /app
ARG VERSION
RUN apk update && apk add curl
RUN curl https://datomic-pro-downloads.s3.amazonaws.com/${VERSION}/datomic-pro-${VERSION}.zip -O
RUN unzip datomic-pro-${VERSION}.zip
RUN mv ./datomic-pro-${VERSION} ./datomic-pro
COPY transactor.properties ./datomic-pro/config/transactor.properties
COPY . .
RUN chmod +x ./*.sh

FROM postgres:12.19-alpine as prod
WORKDIR /app
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV POSTGRES_DB=datomic
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV DATOMIC_STORAGE_ADMIN_PASSWORD=admin
ENV DATOMIC_STORAGE_DATOMIC_PASSWORD=datomic
ENV DATOMIC_HOST=0.0.0.0
ENV DATOMIC_ALT_HOST=localhost
COPY --from=base $JAVA_HOME $JAVA_HOME
COPY --from=base /app/datomic-pro .
COPY --from=base /app/datomic-pro/bin/sql/postgres-table.sql /docker-entrypoint-initdb.d/
COPY --from=base /app/datomic-pro/bin/sql/postgres-user.sql /docker-entrypoint-initdb.d/
COPY --from=base /app/*.sh .
RUN ls -a
VOLUME ["/app/data"]
EXPOSE 4334
EXPOSE 4335
EXPOSE 5432
EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]
