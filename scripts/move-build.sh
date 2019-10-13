#!/bin/bash

#####################################################
# Move Move created project to your Websites folder #
#####################################################

# Load env variables
source .env
source scripts/var.sh

APPS_PATH=${ENV_APPS_DIRECTORY}

_move() {
    if [ ! -d "${APPS_PATH}/${ENV_PROJECT_TEAM}" ]; then
        cp -r ${PROJECT_BASE_PATH} ${APPS_PATH}
    else
        cp -r ${PROJECT_BASE_PATH}/${ENV_PROJECT_NAME} ${APPS_PATH}/${ENV_PROJECT_TEAM}
    fi

    cp .env ${APPS_PATH}/${ENV_PROJECT_TEAM}/${ENV_PROJECT_NAME}/.env-project

    ( cd ${PROJECT_BASE_PATH}/${ENV_PROJECT_NAME} && make up )
}

execute() {
    _move
}

execute