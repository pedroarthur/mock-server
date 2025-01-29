FROM debian:bookworm-slim AS base

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN adduser mockserver

FROM base AS build

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN \
    apt-get update -yq && \
    apt-get install -yq \
      maven \
      openjdk-17-jdk-headless \
    && \
    : ;

WORKDIR /home/mockserver
USER mockserver

COPY --chown=mockserver:mockserver . .

RUN mvn compile test package

FROM base AS release

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN \
    apt-get update -yq && \
    apt-get install -yq \
      openjdk-17-jre-headless \
    && \
    : ;

WORKDIR /home/mockserver
USER mockserver

COPY --from=build \
    /home/mockserver/mockserver-netty/target/mockserver-netty-*-jar-with-dependencies.jar \
    /home/mockserver/mockserver.jar

ENTRYPOINT ["java", "-jar", "mockserver.jar"]