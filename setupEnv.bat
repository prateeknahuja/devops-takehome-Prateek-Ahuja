#!/bin/bash
# Build the Docker image for gkeconnect. This will create a base image called gkeconnect:local on the local machine
# which will have the complete gcloud-sdk, kubectl and Terraform installed.
# The manifests and provisioning files are baked into the image which can then be used by Terraform to create a new cluster.  
docker build -t gkeconnect:local -f ./docker/gkeconnect/Dockerfile .