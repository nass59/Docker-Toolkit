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

    if ${ENV_ENABLE_NGINX} ; then _config_ngnix; fi
    if ${ENV_ENABLE_PHP} ; then _config_php; fi
}

_build_networks() {
      cat >> ${DOCKER_FILE_PROJECT} <<EOL      
networks:
    ${DOCKER_DEFAULT_NETWORK}:
        external: true
EOL
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
                    cpus: "0.1"
                    memory: 50M
        volumes:
            - \${PROJECT_PATH}/:/application:rw,cached
            - \${PROJECT_PATH}/docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
            - \${PROJECT_PATH}/docker/nginx/secrets:/run/secrets:ro
        ports:
            - "${ENV_PORT}:443"
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
        networks:
            - ${DOCKER_DEFAULT_NETWORK}

EOL
}

execute() {
    _create_tmp_project_directories
    _build_header
    _build_services
    _build_networks
}

execute
