#!/bin/bash

##################################
# Create Nginx for a PHP project #
##################################

# Load env variables
source .env
source scripts/var.sh

# Specify the nginx.conf
# Example: build/my-team/my-project/docker/nginx
NGINX_CONFIG_DIR=${DOCKER_DIR_PROJECT}/nginx

# Specify the nginx.conf
# Example: build/my-team/my-project/Makefile
NGINX_CONFIG_FILE=${NGINX_CONFIG_DIR}/nginx.conf

# Specify the public directory
# Example: build/my-team/my-project/public
PUBLIC_DIR=${PROJECT_BASE_PATH}/${ENV_PROJECT_NAME}/public

# Specify the entrypoint
# Example: build/my-team/my-project/public/index.php
ENTRYPOINT=${PUBLIC_DIR}/index.php

_create_nginx_file() {
    mkdir -p ${NGINX_CONFIG_DIR}
    touch ${NGINX_CONFIG_FILE}
}

_build_file() {
    cat > ${NGINX_CONFIG_FILE} <<EOL
#####################################################
# This file has been generated from the Dev Toolkit #
#####################################################

server {
    listen                80;
    listen                443 ssl;
    server_name           ${ENV_PROJECT_NAME}.${ENV_PROJECT_TEAM}.dev;
    ssl_certificate       /run/secrets/site.crt;
    ssl_certificate_key   /run/secrets/site.key;

    client_max_body_size 108M;

    access_log /var/log/nginx/application.access.log;
    error_log /var/log/nginx/application.error.log;

    root /application/public;
    index index.php;

    if (!-e \$request_filename) {
        rewrite ^.*$ /index.php last;
    }

    location ~ \.php$ {
        fastcgi_pass ${ENV_PROJECT_TEAM}_${ENV_PROJECT_NAME}_php-fpm:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PHP_VALUE "error_log=/var/log/nginx/application_php_errors.log";
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        include fastcgi_params;
    }
}
EOL
}

_create_entrypoint() {
    mkdir ${PUBLIC_DIR}
    touch ${ENTRYPOINT}
}

_build_entrypoint() {
    cat > ${ENTRYPOINT} <<EOL
<?php

echo "Hello World";
EOL
}

execute() {
    _create_nginx_file
    _build_file
    _create_entrypoint
    _build_entrypoint
}

execute