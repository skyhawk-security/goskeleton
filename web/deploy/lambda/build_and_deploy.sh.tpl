#!/bin/bash

set -e

S3_ARTIFACT_BUCKET=$1
FUNCTION_NAME={{ .ServiceName }}

if [ ! $# -eq 1 ]; then
    echo "arguments missing: S3 artifact bucket"
    exit 1
fi

# Install AWS SAM
OS="$(uname -s)"
if ! command -v sam &>/dev/null; then
  echo "AWS SAM CLI installation completed."
  if [ "$OS" = "Linux" ]; then
      echo "Installing AWS SAM CLI for Linux..."
      wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
      unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
      sudo ./sam-installation/install
  elif [ "$OS" = "Darwin" ]; then
      echo "Installing AWS SAM CLI for macOS..."
      brew tap aws/tap
      brew install aws-sam-cli
  else
      echo "Unsupported operating system: $OS"
      exit 1
  fi
fi


#build
go mod tidy
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o main cmd/lambda/main.go

# prepare
mkdir -p dist/
cp main dist/
cp deploy/lambda/cloudformation-template.yaml dist/

# package
sam package --metadata function=$FUNCTION_NAME --s3-prefix $FUNCTION_NAME --template-file dist/cloudformation-template.yaml --s3-bucket $S3_ARTIFACT_BUCKET --output-template-file dist/packaged.yaml

# deploy
sam deploy --template-file dist/packaged.yaml --stack-name "$FUNCTION_NAME" --capabilities CAPABILITY_IAM

exit 0