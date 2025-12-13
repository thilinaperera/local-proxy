#!/bin/bash

# Check mkcert is installed
if ! command -v mkcert &> /dev/null
then
    echo "mkcert could not be found. Please install it first."
    exit 1
fi

mkdir -p certs
mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "eng-local.app" "*.eng-local.app"
CAROOT=$(mkcert -CAROOT)
echo "CA cert path: $CAROOT"
