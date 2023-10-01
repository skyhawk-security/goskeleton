#!/bin/bash

set -e

FUNCTION_NAME={{ .ServiceName }}

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

#build
echo "building lambda binary"
go mod tidy
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o main cmd/lambda/main.go

if [[ "$local_invoke" == "true" ]];
then
  sam local invoke $FUNCTION_NAME --template deploy/lambda/cloudformation-template.yaml --event $EVENT_PATH
  exit $?
fi


# prepare
mkdir -p dist/
cp main dist/
cp deploy/lambda/cloudformation-template.yaml dist/

# package
sam package --metadata function=$FUNCTION_NAME --s3-prefix $FUNCTION_NAME --template-file dist/cloudformation-template.yaml --s3-bucket $S3_ARTIFACT_BUCKET --output-template-file dist/packaged.yaml

# deploy
sam deploy --template-file dist/packaged.yaml --stack-name "$FUNCTION_NAME" --capabilities CAPABILITY_IAM

exit 0