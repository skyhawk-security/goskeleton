#!/bin/bash

set -e

FUNCTION_NAME={{ .ServiceName }}

SCRIPT_PATH="$(realpath "$0")"
DIR_PATH=$(dirname "$SCRIPT_PATH")
PARENT_DIR_PATH=$(dirname $(dirname "$DIR_PATH"))

if [ "$PWD" != "$PARENT_DIR_PATH" ]
then
  echo "ERROR: you have to execute the generation command from the service's root: $PARENT_DIR_PATH"
  exit 1
fi

if [ $# -ne 2 ]; then
  echo "you have to provide 2 arguments"
  exit 1
fi

case $1 in
    "deploy")
        S3_ARTIFACT_BUCKET=$2
        ;;
    "local-invoke")
        EVENT_PATH=$2
        local_invoke=true
        ;;
    *)
        echo "first argument should be deploy or local-invoke"
        ;;
esac



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

# generate server
if [ -d "api" ]; then
    echo "generating server"
    ./api/generate_server.sh
fi

# build
sam build --template deploy/lambda/cloudformation-template.yaml

if [[ "$local_invoke" == "true" ]];
then
  sam local invoke $FUNCTION_NAME --template deploy/lambda/cloudformation-template.yaml --event $EVENT_PATH
  exit $?
fi

# package
sam package --metadata function=$FUNCTION_NAME --s3-prefix $FUNCTION_NAME --template-file deploy/lambda/cloudformation-template.yaml --s3-bucket $S3_ARTIFACT_BUCKET --output-template-file packaged.yaml

# deploy
sam deploy --template-file packaged.yaml --stack-name "$FUNCTION_NAME" --capabilities CAPABILITY_IAM

exit 0