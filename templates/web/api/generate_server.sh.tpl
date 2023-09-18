#!/bin/bash

#!/bin/bash

if ! which oapi-codegen >/dev/null 2>&1; then
    echo "oapi-codegen is not installed, installing."
    go install github.com/deepmap/oapi-codegen/cmd/oapi-codegen@latest
fi

oapi-codegen -generate chi-server,types,spec -package server openapi.yaml > server.go
