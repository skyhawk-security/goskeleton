#!/bin/bash

#!/bin/bash

if ! which oapi-codegen >/dev/null 2>&1; then
    echo "oapi-codegen is not installed, installing."
    go install github.com/deepmap/oapi-codegen/cmd/oapi-codegen@latest
fi

oapi-codegen -config server.cfg.yaml openapi.yaml
go mod tidy