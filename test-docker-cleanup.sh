#!/bin/bash

# Cleanup script for Lemmy UI test containers

echo "Stopping and removing test containers..."
docker stop lemmy-test-nginx lemmy-test-ui lemmy-test-backend lemmy-test-pictrs lemmy-test-postgres 2>/dev/null || true
docker rm lemmy-test-nginx lemmy-test-ui lemmy-test-backend lemmy-test-pictrs lemmy-test-postgres 2>/dev/null || true

echo "Removing test network..."
docker network rm lemmy-test-network 2>/dev/null || true

echo "Removing test volumes (optional - comment out if you want to keep data)..."
docker volume rm lemmy-test-postgres-data lemmy-test-pictrs-data 2>/dev/null || true

echo "Cleanup complete!"
