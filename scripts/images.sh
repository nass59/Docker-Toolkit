#!/bin/bash

#######################
# Build Docker images #
#######################

imagesPHP=(
    "php73"
)

_success() {
    echo -e "\033[32m ✔ Success\n\033[37m"
}

execute() {
    echo -e "\n\033[35m==========  Building Docker images  ==========\n\033[37m"

    for i in ${imagesPHP[*]}; do
        PATH_IMAGE=$PWD/images/php/${i}

        if [ ! -d "$PATH_IMAGE" ]; then
            echo "The Directory ${PATH_IMAGE} is not created yet."
        else
            docker build -t ${i} $PATH_IMAGE
        fi
    done

    _success
}

execute
