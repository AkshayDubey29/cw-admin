#!/bin/bash

# Script to create GCR repository for cw-admin

set -e

PROJECT_ID="createworx"
IMAGE_NAME="createworx/cw-admin"

echo "🔧 Setting up GCR repository for cw-admin..."

# Set the project
gcloud config set project $PROJECT_ID

# Enable Container Registry API if not already enabled
echo "Enabling Container Registry API..."
gcloud services enable containerregistry.googleapis.com

# Configure Docker for GCR
echo "Configuring Docker for GCR..."
gcloud auth configure-docker

# Create a simple test image to ensure the repository works
echo "Creating test image..."
docker build -t gcr.io/$IMAGE_NAME:test .

# Push the test image
echo "Pushing test image to GCR..."
docker push gcr.io/$IMAGE_NAME:test

echo "✅ GCR repository setup completed!"
echo "Repository: gcr.io/$IMAGE_NAME"
echo "Test image: gcr.io/$IMAGE_NAME:test"
