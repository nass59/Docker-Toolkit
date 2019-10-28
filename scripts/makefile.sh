#!/bin/bash

##########################################
# Create Makefile for a specific project #
##########################################

# Load env variables
source .env
source scripts/var.sh

# Specify the Makefile
# Example: build/my-team/my-project/Makefile
MAKEFILE_FILE=${PROJECT_BASE_PATH}/${ENV_PROJECT_NAME}/Makefile

_create_makefile() {
    if [ -f "${MAKEFILE_FILE}" ]; then
        rm ${MAKEFILE_FILE}
    fi

    touch ${MAKEFILE_FILE}
}

_build_file() {
    cat > ${MAKEFILE_FILE} <<EOL
#####################################################
# This file has been generated from the Dev Toolkit #
#####################################################

EXEC=./docker/scripts/exec.sh

.DEFAULT_GOAL := help
.PHONY: help

help:
		@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)|(^##)' \$(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-25s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

##---------------------------------------------------------------------------
## Docker
##---------------------------------------------------------------------------

init: ## Init project
init: env up install

up: ## Deploy the stack
	\$(EXEC) deploy
	\$(EXEC) info

down: ## Remove the stack
	\$(EXEC) remove

info: ## Display container ID
	\$(EXEC) info

exec: ## Go to container
	\$(EXEC) exec

env: ## Set .env file
	\$(EXEC) envs

EOL
}

execute() {
    _create_makefile
    _build_file
}

execute