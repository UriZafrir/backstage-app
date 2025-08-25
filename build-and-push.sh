#!/usr/bin/env bash
set -ex

echo "--- Running prerequisite build steps ---"
yarn install --immutable
yarn tsc
# Corrected the workspace name from '@backstage/backend' to 'backend'
yarn workspace backend build
echo "--- Build steps complete ---"


echo "--- Building and pushing Docker image ---"
docker build -f packages/backend/Dockerfile . --tag urizaf/backstage-app
docker push urizaf/backstage-app:latest
echo "--- Docker image pushed successfully ---"