#!/bin/bash

set -e

SERVICE_NAME=[[[ .ServiceName ]]]

export AWS_PAGER=""
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"
IMAGE_TAG=$(date +%Y%m%d%H%M%S)
IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${SERVICE_NAME}:${IMAGE_TAG}"
TEMPLATE_PATH="deploy/ecs/cloudformation-template.yaml"

deploy_stack() {
  local service_name=$1
  local template_file=$2
  local image_uri=$3

  aws cloudformation deploy \
    --stack-name "$service_name" \
    --template-file "$template_file" \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides ImageURL="$image_uri"
}


if [ -d "api" ]; then
    echo "generating server"
    ./api/generate_server.sh
fi

# ECR repository needs to be created before we push docker images
if ! aws ecr describe-repositories --repository-names "${SERVICE_NAME}" > /dev/null 2>&1; then
  echo "Repository does not exist, creating the stack"
  deploy_stack "$SERVICE_NAME" "$TEMPLATE_PATH" "$IMAGE_URI"
fi

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

docker buildx create --use
docker buildx build --platform linux/arm64 -t $IMAGE_URI . --push

deploy_stack "$SERVICE_NAME" "$TEMPLATE_PATH" "$IMAGE_URI"

exit 0
