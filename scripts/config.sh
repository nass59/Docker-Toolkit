#!/bin/bash

############################################################
# Create Docker Compose config file for a specific project #
############################################################

# Load env variables
source .env
source scripts/var.sh

# Specify the docker compose filename for the project
# Example: build/my-team/my-project/docker-compose.yaml
DOCKER_FILE_PROJECT=${PROJECT_BASE_PATH}/${ENV_PROJECT_NAME}/docker-compose.yaml

_create_tmp_project_directories() {
    if [ -d "${BUILD_DIRECTORY}" ]; then
        rm -rf ${BUILD_DIRECTORY}
    fi
    
    mkdir -p ${PROJECT_BASE_PATH}/${ENV_PROJECT_NAME}
    touch ${DOCKER_FILE_PROJECT}
}

_build_header() {
      cat > ${DOCKER_FILE_PROJECT} <<EOL
version: "3.3"

EOL
}

_build_services() {
    cat >> ${DOCKER_FILE_PROJECT} <<EOL
services:
EOL

    if ${ENV_SERVICE_ENABLE_NGINX} ; then _config_ngnix; fi
    if ${ENV_SERVICE_ENABLE_PHP} ; then _config_php; fi
    if ${ENV_SERVICE_ENABLE_MONGODB} ; then _config_mongodb; fi
}

_build_networks() {
    cat >> ${DOCKER_FILE_PROJECT} <<EOL
networks:
    ${DOCKER_DEFAULT_NETWORK}:
        external: true
EOL

if ${ENV_SERVICE_ENABLE_MONGODB} ; then
   cat >> ${DOCKER_FILE_PROJECT} <<EOL
    ${ENV_PROJECT_TEAM}_${ENV_PROJECT_NAME}_mongodb:
EOL
fi
}

_config_ngnix() {
    cat >> ${DOCKER_FILE_PROJECT} <<EOL
    ngnix:
        image: nginx:alpine
        working_dir: /application
        deploy:
            replicas: 1
            restart_policy:
                condition: on-failure
            resources:
                limits:
                    cpus: "0.5"
                    memory: 1G
        volumes:
            - \${PROJECT_PATH}/:/application:rw,cached
            - \${PROJECT_PATH}/docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
            - \${PROJECT_PATH}/docker/nginx/secrets:/run/secrets:ro
        ports:
            - "${ENV_PORT_APP}:443"
        networks:
            - ${DOCKER_DEFAULT_NETWORK}

EOL
}

_config_php() {
    cat >> ${DOCKER_FILE_PROJECT} <<EOL
    php-fpm:
        image: php${ENV_VERSION_PHP//./}:latest
        working_dir: /application
        volumes:
            - \${PROJECT_PATH}:/application:rw,cached
EOL

## Add Environment Variables
if ${ENV_FRAMEWORK_ENABLE_SYMFONY} ; then
   cat >> ${DOCKER_FILE_PROJECT} <<EOL
        environment:
            - APP_ENV=dev
EOL
fi

## Add Networks
cat >> ${DOCKER_FILE_PROJECT} <<EOL
        networks:
            - ${DOCKER_DEFAULT_NETWORK}
EOL

## Add Networks for mongodb
if ${ENV_SERVICE_ENABLE_MONGODB} ; then
   cat >> ${DOCKER_FILE_PROJECT} <<EOL
            - ${ENV_PROJECT_TEAM}_${ENV_PROJECT_NAME}_mongodb
EOL
fi

cat >> ${DOCKER_FILE_PROJECT} <<EOL

EOL
}

_config_mongodb() {
    cat >> ${DOCKER_FILE_PROJECT} <<EOL
    mongo:
        image: mongo:${ENV_VERSION_MONGODB}
        volumes:
            - ${ENV_STORAGE_PATH_MONGO}:/data/db
        ports:
            - "${ENV_PORT_MONGODB}:27017"
        command: mongod --storageEngine wiredTiger --directoryperdb --wiredTigerDirectoryForIndexes
        networks:
            - ${ENV_PROJECT_TEAM}_${ENV_PROJECT_NAME}_mongodb

EOL
}

execute() {
    _create_tmp_project_directories
    _build_header
    _build_services
    _build_networks
}

execute
