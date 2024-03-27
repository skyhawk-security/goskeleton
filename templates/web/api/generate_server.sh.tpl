#!/bin/bash

set -e

SCRIPT_PATH="$(realpath "$0")"
DIR_PATH=$(dirname "$SCRIPT_PATH")
PARENT_DIR_PATH=$(dirname "$DIR_PATH")

if [ "$PWD" != "$PARENT_DIR_PATH" ]
then
  echo "ERROR: you have to execute the generation command from the service's root: $PARENT_DIR_PATH"
  exit 1
fi

if ! which oapi-codegen >/dev/null 2>&1; then
    echo "oapi-codegen is not installed, installing."
    go install github.com/deepmap/oapi-codegen/cmd/oapi-codegen@latest
fi

oapi-codegen -config api/server.cfg.yaml api/openapi.yaml
go mod tidy