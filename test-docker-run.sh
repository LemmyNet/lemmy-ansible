#!/bin/bash

# Script to test Lemmy UI image using docker run commands
# Image: dessalines/lemmy-ui:0.19.15-alpha.1

set -e

echo "================================================"
echo "Testing Lemmy UI image with docker run commands"
echo "Image: dessalines/lemmy-ui:0.19.15-alpha.1"
echo "================================================"
echo ""

# Create a custom network
echo "Creating Docker network 'lemmy-test-network'..."
docker network create lemmy-test-network 2>/dev/null || echo "Network already exists"

# Start PostgreSQL
echo "Starting PostgreSQL..."
docker run -d \
  --name lemmy-test-postgres \
  --network lemmy-test-network \
  -e POSTGRES_USER=lemmy \
  -e POSTGRES_PASSWORD=test-password-123 \
  -e POSTGRES_DB=lemmy \
  -v lemmy-test-postgres-data:/var/lib/postgresql/data \
  postgres:16-alpine

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 5

# Start Pictrs
echo "Starting Pictrs..."
docker run -d \
  --name lemmy-test-pictrs \
  --network lemmy-test-network \
  -e PICTRS__SERVER__API_KEY=test-api-key-123 \
  -e RUST_LOG=info \
  --user 991:991 \
  -v lemmy-test-pictrs-data:/mnt \
  asonix/pictrs:0.5

# Start Lemmy backend
echo "Starting Lemmy backend..."
docker run -d \
  --name lemmy-test-backend \
  --network lemmy-test-network \
  -e RUST_LOG=warn \
  -v "$(pwd)/test-lemmy.hjson:/config/config.hjson:ro" \
  dessalines/lemmy:0.19.15-alpha.1

# Wait for Lemmy backend to initialize
echo "Waiting for Lemmy backend to initialize..."
sleep 10

# Start Lemmy UI (the image we're testing)
echo "Starting Lemmy UI (dessalines/lemmy-ui:0.19.15-alpha.1)..."
docker run -d \
  --name lemmy-test-ui \
  --network lemmy-test-network \
  -e LEMMY_UI_LEMMY_INTERNAL_HOST=lemmy-test-backend:8536 \
  -e LEMMY_UI_LEMMY_EXTERNAL_HOST=localhost:1236 \
  -e LEMMY_UI_HTTPS=false \
  dessalines/lemmy-ui:0.19.15-alpha.1

# Start Nginx proxy
echo "Starting Nginx proxy..."
docker run -d \
  --name lemmy-test-nginx \
  --network lemmy-test-network \
  -p 1236:8536 \
  -v "$(pwd)/test-nginx.conf:/etc/nginx/nginx.conf:ro" \
  nginx:latest

echo ""
echo "================================================"
echo "Lemmy UI test instance is starting up!"
echo "================================================"
echo ""
echo "Access the UI at: http://localhost:1236"
echo ""
echo "To view logs:"
echo "  docker logs -f lemmy-test-ui"
echo ""
echo "To stop and remove all test containers:"
echo "  docker stop lemmy-test-nginx lemmy-test-ui lemmy-test-backend lemmy-test-pictrs lemmy-test-postgres"
echo "  docker rm lemmy-test-nginx lemmy-test-ui lemmy-test-backend lemmy-test-pictrs lemmy-test-postgres"
echo "  docker network rm lemmy-test-network"
echo "  docker volume rm lemmy-test-postgres-data lemmy-test-pictrs-data"
echo ""
echo "Or run: ./test-docker-cleanup.sh"
echo ""
