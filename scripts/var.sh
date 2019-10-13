#!/bin/bash

############################################################
# Set up variables #
############################################################

# Specify the build directory
BUILD_DIRECTORY=build

# Project Base Path
# Example: build/my-team
PROJECT_BASE_PATH=${BUILD_DIRECTORY}/${ENV_PROJECT_TEAM}

# Specify the Docker Directory for the project
# Example: build/my-team/my-project/docker
DOCKER_DIR_PROJECT=${PROJECT_BASE_PATH}/${ENV_PROJECT_NAME}/docker

# Add a default network
DOCKER_DEFAULT_NETWORK=${ENV_PROJECT_NAME}_default

# Specify the HTTPS certificates directory
CERTS_BASE_PATH=./scripts/https
