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

# The full name of the remote images.
REMOTE_BACKEND_IMAGE = $(REMOTE_REGISTRY)/$(APP_NAME)-backend
REMOTE_FRONTEND_IMAGE = $(REMOTE_REGISTRY)/$(APP_NAME)-frontend

# ==============================================================================
# Targets
# ==============================================================================

.PHONY: all build-and-push-to-remote build-to-k3s build-backend build-frontend docker-build-backend docker-build-frontend push-to-remote load-to-k3s install

# Default target (build and push both)
all: build-and-push-to-remote

# Build and push both images to a remote registry
build-and-push-to-remote: push-to-remote

# Build both images and load into k3s
build-to-k3s: load-to-k3s

# Build the backend package
build-backend: install
	@echo "--- Running prerequisite build steps for backend ---"
	yarn tsc
	yarn workspace backend build --config ../../app-config.production.yaml
	@echo "--- Backend build steps complete ---"

# Build the frontend package
build-frontend: install
	@echo "--- Building frontend ---"
	yarn workspace app build --config ../../app-config.production.yaml
	@echo "--- Frontend build complete ---"

# Build the backend Docker image
docker-build-backend: build-backend
	@echo "--- Building backend Docker image ---"
	docker build -f packages/backend/Dockerfile . --tag $(REMOTE_BACKEND_IMAGE):$(IMAGE_TAG)

# Build the frontend Docker image
docker-build-frontend: build-frontend
	@echo "--- Building frontend Docker image ---"
	docker build -f packages/app/Dockerfile . --tag $(REMOTE_FRONTEND_IMAGE):$(IMAGE_TAG)

# Build both Docker images
docker-build: docker-build-backend docker-build-frontend

# Push both Docker images to the remote registry
push-to-remote: docker-build
	@echo "--- Pushing backend Docker image to remote registry ---"
	docker push $(REMOTE_BACKEND_IMAGE):$(IMAGE_TAG)
	@echo "--- Pushing frontend Docker image to remote registry ---"
	docker push $(REMOTE_FRONTEND_IMAGE):$(IMAGE_TAG)
	@echo "--- Docker images pushed successfully ---"

# Load both Docker images into the k3s cluster
load-to-k3s: docker-build
	@echo "--- Loading backend Docker image into k3s ---"
	sudo k3s ctr images import - < <(docker save $(REMOTE_BACKEND_IMAGE):$(IMAGE_TAG))
	@echo "--- Loading frontend Docker image into k3s ---"
	sudo k3s ctr images import - < <(docker save $(REMOTE_FRONTEND_IMAGE):$(IMAGE_TAG))
	@echo "--- Docker images loaded successfully into k3s ---"
	@echo "--- Restarting Backstage pods ---"
	kubectl delete pod -n backstage -l app.kubernetes.io/name=backstage-app
	kubectl delete pod -n backstage -l app.kubernetes.io/name=backstage-backend
	sleep 1
	@echo "--- Logs for the backend... ---"
	kubectl logs -f -l app.kubernetes.io/name=backstage-backend -n backstage

# Install dependencies
install:
	@echo "--- Installing dependencies ---"
	yarn install --immutable