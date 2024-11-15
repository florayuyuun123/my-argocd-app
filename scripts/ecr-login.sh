#!/bin/bash
# Login to Amazon ECR
# Ensure AWS_REGION and ECR_REGISTRY are passed as environment variables

if [ -z "$AWS_REGION" ] || [ -z "$ECR_REGISTRY" ]; then
  echo "Error: Missing AWS_REGION or ECR_REGISTRY environment variable."
  exit 1
fi

# Authenticate Docker with Amazon ECR
echo "Logging in to Amazon ECR in region $AWS_REGION for registry $ECR_REGISTRY..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

if [ $? -eq 0 ]; then
  echo "Amazon ECR login successful."
else
  echo "Amazon ECR login failed."
  exit 1
fi
