#!/bin/bash

########################
# Generate Certificate #
########################

# Load env variables
source .env
source scripts/var.sh

certsDir=${CERTS_BASE_PATH}/certs
certsConfDir=${CERTS_BASE_PATH}/certs_conf
secretsDir=${CERTS_BASE_PATH}/secrets

C=FR
ST=Ile-de-france
L=Paris
O=Dev
CN=*.${ENV_PROJECT_TEAM}.dev

success() {
    echo -e "\033[32m ✔ Success\n"
}

message() {
    echo -e "\033[90m $1"
}

generateRootKey() {
    message "1 - Generating the root key..."

    openssl genrsa -out "$certsDir/root-ca.key" 4096

    success
}

generateCSR() {
    message "2 - Generating a CSR using the root key..."

    openssl req \
        -new -key "$certsDir/root-ca.key" \
        -out "$certsDir/root-ca.csr" -sha256 \
        -subj '/C='$C'/ST='$ST'/L='$L'/O='$O'/CN='$CN''

    success
}

signCertificate() {
    message "3 - Signing the certificate..."

    openssl x509 -req -days 3650 -in "$certsDir/root-ca.csr" \
        -signkey "$certsDir/root-ca.key" -sha256 -out "$certsDir/root-ca.crt" \
        -extfile "$certsConfDir/root-ca.cnf" -extensions \
        root_ca

    success
}

generateSiteKey() {
    message "4 - Generating the site key..."

    openssl genrsa -out "${secretsDir}/${ENV_PROJECT_TEAM}/site.key" 4096

    success
}

generateSiteCertification() {
    message "5 - Generating the site certificate and sign it with the site key."

    openssl req -new -key "${secretsDir}/${ENV_PROJECT_TEAM}/site.key" -out "$certsDir/site.csr" -sha256 \
        -subj '/C='$C'/ST='$ST'/L='$L'/O='$O'/CN='$CN''

    success
}

signSiteCertificate() {
    message "6 - Signing the site certificate."

    build_site_cnf

    openssl x509 -req -days 750 -in "$certsDir/site.csr" -sha256 \
        -CA "$certsDir/root-ca.crt" -CAkey "$certsDir/root-ca.key" -CAcreateserial \
        -out "${secretsDir}/${ENV_PROJECT_TEAM}/site.crt" -extfile "$certsConfDir/site.cnf" -extensions server

    success
}

build_site_cnf() {
    pathSiteCnf=${certsConfDir}/site.cnf
    
    if [ -f "${pathSiteCnf}" ]; then
        rm ${pathSiteCnf}
    fi

    touch ${pathSiteCnf}

    cat >> ${pathSiteCnf} <<EOL
[server]
authorityKeyIdentifier=keyid,issuer
basicConstraints = critical,CA:FALSE
extendedKeyUsage=serverAuth
keyUsage = critical, digitalSignature, keyEncipherment
subjectAltName = DNS:*.${ENV_PROJECT_TEAM}.dev, IP:127.0.0.1
subjectKeyIdentifier=hash
EOL
}

generateCerts() {
    echo -e "\n\033[35m==========  Generating HTTPS Certificates  ==========\n\033[37m"

    if [ -d "${secretsDir}/${ENV_PROJECT_TEAM}" ]; then
        _copy_certs
        exit 0
    fi

    if [ ! -d $certsDir ]; then
        mkdir $certsDir
    fi

    if [ ! -d "${secretsDir}/${ENV_PROJECT_TEAM}" ]; then
        mkdir ${secretsDir}/${ENV_PROJECT_TEAM}
    fi

    generateRootKey
    generateCSR
    signCertificate

    generateSiteKey
    generateSiteCertification
    signSiteCertificate

    _copy_certs
    _clean
}

_copy_certs() {
    path_secrets_build=${PROJECT_BASE_PATH}/${ENV_PROJECT_NAME}/docker/nginx/secrets/

    if [ ! -d $path_secrets_build ]; then
        mkdir $path_secrets_build
    fi

    cp -r ${secretsDir}/${ENV_PROJECT_TEAM}/site.crt ${path_secrets_build}
    cp -r ${secretsDir}/${ENV_PROJECT_TEAM}/site.key ${path_secrets_build}
}

_clean() {
    rm .srl
}

execute() {
    if [ -f ${secretsDir}/${ENV_PROJECT_TEAM}/sites.crt -a -f ${secretsDir}/${ENV_PROJECT_TEAM}/site.key ]; then
        echo -e "\033[32m HTTPS environment already configured\n"
    else
        generateCerts
    fi
}

execute
