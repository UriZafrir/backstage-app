# Makefile for building and pushing the Backstage application

# ==============================================================================
# Variables
# ==============================================================================

# The name of the remote Docker registry/organization.
# Change this to your own registry if you are not using Docker Hub.
REMOTE_REGISTRY ?= local

# The name of the application.
APP_NAME ?= backstage-app

# The tag for the Docker image.
IMAGE_TAG ?= latest

# The full name of the remote image.
REMOTE_IMAGE = $(REMOTE_REGISTRY)/$(APP_NAME)

# ==============================================================================
# Targets
# ==============================================================================

.PHONY: all build-and-push-to-remote build-to-k3s build docker-build push-to-remote load-to-k3s install

# Default target
all: build-and-push-to-remote

# Build and push the image to a remote registry
build-and-push-to-remote: push-to-remote

# Build the image and load it into the local k3s cluster
build-to-k3s: load-to-k3s

# Build the backend package to generate artifacts for the Docker build
build: install
	@echo "--- Running prerequisite build steps ---"
	yarn tsc
	yarn workspace backend build
	@echo "--- Build steps complete ---"

# Build the Docker image
docker-build: build
	@echo "--- Building Docker image ---"
	docker build -f packages/backend/Dockerfile . --tag $(REMOTE_IMAGE):$(IMAGE_TAG)
	#docker build --no-cache -f packages/backend/Dockerfile . --tag $(REMOTE_IMAGE):$(IMAGE_TAG)

# Push the Docker image to the remote registry
push-to-remote: docker-build
	@echo "--- Pushing Docker image to remote registry ---"
	docker push $(REMOTE_IMAGE):$(IMAGE_TAG)
	@echo "--- Docker image pushed successfully to $(REMOTE_IMAGE):$(IMAGE_TAG) ---"

# Load the Docker image into the k3s cluster
load-to-k3s: docker-build
	@echo "--- Loading Docker image into k3s ---"
	sudo k3s ctr images import - < <(docker save $(REMOTE_IMAGE):$(IMAGE_TAG))
	@echo "--- Docker image loaded successfully into k3s ---"

# Install dependencies
install:
	@echo "--- Installing dependencies ---"
	yarn install --immutable