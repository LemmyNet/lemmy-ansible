# Testing Lemmy UI Docker Image

This directory contains test configurations for the Lemmy UI Docker image: `dessalines/lemmy-ui:0.19.15-alpha.1`

## Quick Start

### Option 1: Using Docker Compose (Recommended)

This is the easiest way to test the Lemmy UI image with all required dependencies:

```bash
# Start the test environment
docker compose -f docker-compose.test.yml up -d

# View logs
docker compose -f docker-compose.test.yml logs -f lemmy-ui

# Access the UI
# Open http://localhost:1236 in your browser

# Stop and clean up
docker compose -f docker-compose.test.yml down -v
```

### Option 2: Using Docker Run Commands

If you prefer using individual `docker run` commands:

```bash
# Start all services
./test-docker-run.sh

# View logs
docker logs -f lemmy-test-ui

# Access the UI
# Open http://localhost:1236 in your browser

# Clean up
./test-docker-cleanup.sh
```

### Option 3: Manual Docker Run (Minimal)

To test just the Lemmy UI container in isolation (note: this won't be fully functional without backend):

```bash
docker run -d \
  --name lemmy-ui-test \
  -p 1234:1234 \
  -e LEMMY_UI_LEMMY_INTERNAL_HOST=your-lemmy-backend:8536 \
  -e LEMMY_UI_LEMMY_EXTERNAL_HOST=localhost:1236 \
  -e LEMMY_UI_HTTPS=false \
  dessalines/lemmy-ui:0.19.15-alpha.1

# View logs
docker logs -f lemmy-ui-test

# Stop and remove
docker stop lemmy-ui-test && docker rm lemmy-ui-test
```

## What's Included

The test setup includes:

- **Lemmy UI** (`dessalines/lemmy-ui:0.19.15-alpha.1`) - The image being tested
- **Lemmy Backend** (`dessalines/lemmy:0.19.15-alpha.1`) - API server
- **PostgreSQL** (`postgres:16-alpine`) - Database
- **Pictrs** (`asonix/pictrs:0.5`) - Image hosting service
- **Nginx** (`nginx:latest`) - Reverse proxy

## Configuration Files

- `docker-compose.test.yml` - Complete Docker Compose setup
- `test-lemmy.hjson` - Lemmy backend configuration
- `test-nginx.conf` - Nginx reverse proxy configuration
- `test-docker-run.sh` - Script to start services with docker run
- `test-docker-cleanup.sh` - Script to clean up test containers

## Accessing the Application

Once the services are running:

1. Open your browser to http://localhost:1236
2. Default admin credentials (if configured):
   - Username: `admin`
   - Password: `admin`

## Environment Variables

The Lemmy UI container uses these environment variables:

- `LEMMY_UI_LEMMY_INTERNAL_HOST` - Internal hostname of Lemmy backend (e.g., `lemmy:8536`)
- `LEMMY_UI_LEMMY_EXTERNAL_HOST` - External hostname for browser access (e.g., `localhost:1236`)
- `LEMMY_UI_HTTPS` - Whether to use HTTPS (set to `false` for local testing)

## Troubleshooting

### Services won't start

```bash
# Check logs for specific service
docker compose -f docker-compose.test.yml logs lemmy-ui
docker compose -f docker-compose.test.yml logs lemmy
docker compose -f docker-compose.test.yml logs postgres

# Restart services
docker compose -f docker-compose.test.yml restart
```

### Port 1236 already in use

Edit `docker-compose.test.yml` and change the port mapping:

```yaml
proxy:
  ports:
    - "8080:8536"  # Change 1236 to any available port
```

### Database connection issues

Wait a bit longer for PostgreSQL to initialize:

```bash
# Check if postgres is healthy
docker compose -f docker-compose.test.yml ps
```

### Clean slate restart

```bash
# Remove all containers, networks, and volumes
docker compose -f docker-compose.test.yml down -v

# Start fresh
docker compose -f docker-compose.test.yml up -d
```

## Notes

- This is a **test configuration** and should not be used in production
- Uses simple passwords for testing purposes only
- Data is stored in Docker volumes (removed with `-v` flag on down)
- The UI is accessible on port 1236 (configurable)

## More Information

- [Lemmy Documentation](https://join-lemmy.org/docs)
- [Lemmy UI Repository](https://github.com/LemmyNet/lemmy-ui)
- [Lemmy Ansible Repository](https://github.com/LemmyNet/lemmy-ansible)
