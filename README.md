# Kubernetes DevOps Pipeline (AWS)

## Overview

This project sets up a CI/CD pipeline using GitHub Actions for building, testing, and deploying an application to an AWS Elastic Kubernetes Service (EKS) cluster. The pipeline also utilizes AWS Elastic Container Registry (ECR) for storing Docker images and ArgoCD for GitOps-based deployments.

## Steps to Deploy

1. **Set Up AWS Services**:
   - **ECR**: Create an Elastic Container Registry (ECR) repository to store Docker images.
   - **EKS**: Create an Elastic Kubernetes Service (EKS) cluster.

2. **Configure GitHub Secrets**:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
   - `AWS_REGION`: Your AWS region.
   - `ECR_REGISTRY`: The URI of your ECR registry.
   - `ECR_REPOSITORY`: The name of your ECR repository.
   - `KUBE_CONFIG`: Your base64-encoded Kubernetes config for EKS.

3. **Set Up ArgoCD**:
   - Install ArgoCD on the EKS cluster and connect it to your GitHub repository.
   - Create an ArgoCD application that will sync Kubernetes configurations from the `config/k8s` folder.

4. **Build and Deploy**:
   - Push changes to the `main` branch of your GitHub repository.
   - GitHub Actions will automatically build the Docker image and push it to ECR.
   - Kubernetes manifests will be updated and deployed to EKS.

## Notes

- Ensure your Kubernetes manifests are configured properly for your app.
- You can modify the `Dockerfile` and app code based on your requirements.
- For more information on GitHub Actions, check the [GitHub Actions documentation](https://docs.github.com/en/actions).
