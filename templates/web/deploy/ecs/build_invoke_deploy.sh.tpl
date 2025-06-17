#!/bin/bash

set -e

SERVICE_NAME=[[[ .ServiceName ]]]


export AWS_PAGER=""
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"
IMAGE_TAG=$(date +%Y%m%d%H%M%S)
IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${SERVICE_NAME}:${IMAGE_TAG}"

aws cloudformation deploy \
  --stack-name $SERVICE_NAME \
  --template-file deploy/ecs/cloudformation-template.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides ImageURL=$IMAGE_URI

if [ -d "api" ]; then
    echo "generating server"
    ./api/generate_server.sh
fi

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

docker buildx create --use
docker buildx build --platform linux/arm64 -t $IMAGE_URI . --push

exit 0
