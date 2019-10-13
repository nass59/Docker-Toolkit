#!/bin/bash

#############
# Add Hosts #
#############

# Load env variables
source .env
source scripts/var.sh

hosts=(
    ${ENV_PROJECT_NAME}.${ENV_PROJECT_TEAM}.dev
)

HOSTS_FILE="/etc/hosts"
HOSTS_TMP_FILE="/etc/hosts.tmp"

ACTION=$1

_add_hosts() {
    for i in ${hosts[*]}; do
        HOST="127.0.0.1       ${i}"
        grep -q -F "${HOST}" "${HOSTS_FILE}" || echo "${HOST}" >> "${HOSTS_FILE}"
    done
}

_remove_hosts() {
    for i in ${hosts[*]}; do
        PATTERN="/${i}/d"
        sed "${PATTERN}" "${HOSTS_FILE}" > "${HOSTS_TMP_FILE}" && mv "${HOSTS_TMP_FILE}" "${HOSTS_FILE}"
    done
}

execute() {
    if [ $ACTION == "add" ]; then
        _add_hosts
    elif [ $ACTION == "remove" ]; then
        _remove_hosts
    else
        echo "You have to specify if you want to 'add' or 'remove' the hosts"
    fi
}

execute
