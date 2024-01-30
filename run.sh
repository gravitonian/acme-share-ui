#!/bin/sh

export COMPOSE_FILE_PATH="${PWD}/target/classes/docker/docker-compose.yml"

if [ -z "${M2_HOME}" ]; then
  export MVN_EXEC="mvn -DextensionProjectActivation"
else
  export MVN_EXEC="${M2_HOME}/bin/mvn -DextensionProjectActivation"
fi

start() {
    docker volume create acme-share-ui-acs-volume
    docker volume create acme-share-ui-db-volume
    docker volume create acme-share-ui-ass-volume
    docker-compose -f "$COMPOSE_FILE_PATH" up --build -d
}

start_share() {
    docker-compose -f "$COMPOSE_FILE_PATH" up --build -d acme-share-ui-share
}

down() {
    if [ -f "$COMPOSE_FILE_PATH" ]; then
        docker-compose -f "$COMPOSE_FILE_PATH" down
    fi
}

purge() {
    docker volume rm -f acme-share-ui-acs-volume
    docker volume rm -f acme-share-ui-db-volume
    docker volume rm -f acme-share-ui-ass-volume
}

build() {
    $MVN_EXEC clean package
}

build_share() {
    docker-compose -f "$COMPOSE_FILE_PATH" kill acme-share-ui-share
    yes | docker-compose -f "$COMPOSE_FILE_PATH" rm -f acme-share-ui-share
    $MVN_EXEC clean package
}

tail() {
    docker-compose -f "$COMPOSE_FILE_PATH" logs -f
}

tail_all() {
    docker-compose -f "$COMPOSE_FILE_PATH" logs --tail="all"
}

case "$1" in
  build_start)
    down
    build
    start
    tail
    ;;
  start)
    start
    tail
    ;;
  stop)
    down
    ;;
  purge)
    down
    purge
    ;;
  tail)
    tail
    ;;
  reload_share)
    build_share
    start_share
    tail
    ;;
  *)
    echo "Usage: $0 {build_start|start|stop|purge|tail|reload_share}"
esac