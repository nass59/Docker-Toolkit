#!/bin/bash

##################################
# Create Nginx for a PHP project #
##################################

# Load env variables
source .env
source scripts/var.sh

# Specify the Scripts Directory
# Example: build/my-team/my-project/docker/scripts
SCRIPTS_DIR=${DOCKER_DIR_PROJECT}/scripts

# Specify the Script file
# Example: build/my-team/my-project/docker/scripts/exec.sh
SCRIPT_FILE=${SCRIPTS_DIR}/exec.sh

_create_script_file() {
    mkdir ${SCRIPTS_DIR}
    touch ${SCRIPT_FILE}

    sudo chmod -R 777 ${SCRIPTS_DIR}
}

_build_var() {
    cat > ${SCRIPT_FILE} <<EOL
#!/bin/bash

ACTION=\$1
APP_DIR=\$PWD

STACK_NAME=${ENV_PROJECT_TEAM}_${ENV_PROJECT_NAME}
SERVICE_NAME=${ENV_PROJECT_TEAM}_${ENV_PROJECT_NAME}_php-fpm
CONTAINER_ID=\$(docker container ls | grep \$SERVICE_NAME | sed -e 's/^\(.\{12\}\).*/\1/')

EOL
}

_build_func_deploy() {
    cat >> ${SCRIPT_FILE} <<EOL
deploy() {
    echo -e "\n\033[35m==========  Deploying Stack  ==========\n\033[37m"

    env \$(cat \$APP_DIR/.env | grep "^[A-Z]" | xargs) docker stack deploy -c \$APP_DIR/docker-compose.yaml \$STACK_NAME

    echo -e "\n\033[32m ✔ Success! Your stack is ready 🎉 \n\033[37m"
}

EOL
}

_build_func_remove() {
    cat >> ${SCRIPT_FILE} <<EOL
remove() {
    docker stack rm \$STACK_NAME
}

EOL
}

_build_func_info() {
    cat >> ${SCRIPT_FILE} <<EOL
info() {
    echo -e "\n\033[35m==========  Infos  ==========\n\033[37m"

    echo -e "\033[33m Container ID: \033[34m\$CONTAINER_ID\n\033[37m"

    echo -e "\033[33m Hosts:\033[37m"
    echo -e "\033[37m    - ${ENV_PROJECT_NAME} (HTTPS): \033[34m https://${ENV_PROJECT_NAME}.${ENV_PROJECT_TEAM}.dev:${ENV_PORT_APP}\033[37m"

    echo -e "\n\033[33m To go inside the container, run: \033[37m\033[45m make exec \033[37m\033[49m 🐳"
}

EOL
}

_build_func_exec() {
    cat >> ${SCRIPT_FILE} <<EOL
exec() {
    docker exec -it \$CONTAINER_ID bash
}

EOL
}

_build_func_execute() {
    cat >> ${SCRIPT_FILE} <<EOL
execute() {
    \$ACTION
}

execute

EOL
}

execute() {
    _create_script_file
    _build_var
    _build_func_deploy
    _build_func_remove
    _build_func_info
    _build_func_exec
    _build_func_execute
}

execute