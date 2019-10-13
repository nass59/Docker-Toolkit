#!/bin/bash

##################################################
# Create .env config file for a specific project #
##################################################

# Load env variables
source .env
source scripts/var.sh

# Specify the dotenv file
# Example: build/my-team/my-project/.env
DOTENV_FILE=${PROJECT_BASE_PATH}/${ENV_PROJECT_NAME}/.env

_create_env_file() {
    if [ -f "${DOTENV_FILE}" ]; then
        rm ${DOTENV_FILE}
    fi

    touch ${DOTENV_FILE}
}

_build_file() {
    cat > ${DOTENV_FILE} <<EOL
#####################################################
# This file has been generated from the Dev Toolkit #
#####################################################

# Path of the current project
PROJECT_PATH=${ENV_APPS_DIRECTORY}/${ENV_PROJECT_TEAM}/${ENV_PROJECT_NAME}
EOL
}

execute() {
    _create_env_file
    _build_file
}

execute