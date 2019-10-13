#!/bin/bash

############################
# Create External Networks #
############################

# Load env variables
source .env
source scripts/var.sh

ACTION=$1

networks=(
    ${DOCKER_DEFAULT_NETWORK}
)

_success() {
    echo -e "\033[32m ✔ Success\n\033[37m"
}

_create_networks() {
    echo -e "\n\033[35m==========  Creating External Networks  ==========\n\033[37m"

    for i in ${networks[*]}; do
        if [ ! "$(docker network ls | grep ${i})" ]; then
            docker network create -d overlay ${i}
        fi
    done

    _success
}

_remove_networks() {
    echo -e "\n\033[35m==========  Removing External Networks  ==========\n\033[37m"

    for i in ${networks[*]}; do
        if [ "$(docker network ls | grep ${i})" ]; then
            docker network rm ${i}
        fi
    done

    _success
}

execute() {
    if [ $ACTION == "create" ]; then
        _create_networks
    elif [ $ACTION == "remove" ]; then
        _remove_networks
    else
        echo "You have to specify if you want to 'create' or 'remove' the networks"
    fi
}

execute
