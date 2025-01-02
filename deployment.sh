#!/bin/bash

# Ensure BUILD_NUMBER is provided
if [ -z "$BUILD_NUMBER" ]; then
  echo "Error: BUILD_NUMBER is not set."
  exit 1
fi

# Step 1: Git Checkout
echo "Checking out the repository..."
git clone --branch main https://github.com/Lakshman386/pet_shop.git || {
  echo "Error: Failed to clone repository."
  exit 1
}
cd pet_shop || {
  echo "Error: Failed to change directory to pet_shop."
  exit 1
}

# Step 2: Maven Build
echo "Building the project with Maven..."
mvn clean install || {
  echo "Error: Maven build failed."
  exit 1
}

# Step 3: Remove Existing Docker Container and Image
echo "Removing existing Docker container and image..."
sudo docker rm -f my-cont || true
sudo docker rmi lakshman386/pet:${BUILD_NUMBER} || true

# Step 4: Build and Push Docker Image
echo "Building and pushing Docker image..."
docker login -u <your-docker-username> -p <your-docker-password> || {
  echo "Error: Docker login failed."
  exit 1
}
docker build -t lakshman386/pet:${BUILD_NUMBER} . || {
  echo "Error: Docker build failed."
  exit 1
}
docker push lakshman386/pet:${BUILD_NUMBER} || {
  echo "Error: Docker push failed."
  exit 1
}

# Step 5: Update Deployment YAML
echo "Updating deployment YAML..."
sed -i "s|image: .*|image: lakshman386/pet:${BUILD_NUMBER}|" k8s/deployment.yaml || {
  echo "Error: Failed to update deployment YAML."
  exit 1
}

echo "Script execution completed successfully."
