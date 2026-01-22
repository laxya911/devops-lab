#!/bin/bash
# Nexus Initial Configuration Script
# This script configures Nexus after startup

set -e

NEXUS_URL="http://localhost:8081"
ADMIN_PASSWORD_FILE="/nexus-data/admin.password"

# Wait for Nexus to be ready
echo "Waiting for Nexus to be ready..."
while ! curl -s -f "${NEXUS_URL}/service/rest/v1/status" > /dev/null; do
  echo "Nexus not ready yet, waiting..."
  sleep 10
done

echo "Nexus is ready!"

# Get initial admin password
if [ -f "$ADMIN_PASSWORD_FILE" ]; then
  ADMIN_PASSWORD=$(cat "$ADMIN_PASSWORD_FILE")
else
  echo "Admin password file not found at $ADMIN_PASSWORD_FILE"
  exit 1
fi

echo "Initial admin password: $ADMIN_PASSWORD"

# Change admin password and create user
curl -X PUT "${NEXUS_URL}/service/rest/v1/security/users/admin/change-password" \
  -H "Content-Type: application/json" \
  -u "admin:$ADMIN_PASSWORD" \
  -d '{"password": "nexus"}'

echo "Admin password changed to nexus"

# Enable anonymous access (optional)
curl -X PUT "${NEXUS_URL}/service/rest/v1/security/anonymous" \
  -H "Content-Type: application/json" \
  -u "admin:nexus" \
  -d '{"enabled": true}'

# Create Docker hosted repository
curl -X POST "${NEXUS_URL}/service/rest/v1/repositories/docker/hosted" \
  -H "Content-Type: application/json" \
  -u "admin:nexus" \
  -d '{
    "name": "docker-hosted",
    "online": true,
    "storage": {
      "blobStoreName": "default",
      "strictContentTypeValidation": true,
      "writePolicy": "allow"
    },
    "docker": {
      "v1Enabled": false,
      "forceBasicAuth": true,
      "httpPort": 5000
    }
  }'

echo "Docker hosted repository created"

# Create Docker proxy repository for Docker Hub
curl -X POST "${NEXUS_URL}/service/rest/v1/repositories/docker/proxy" \
  -H "Content-Type: application/json" \
  -u "admin:nexus" \
  -d '{
    "name": "docker-proxy",
    "online": true,
    "storage": {
      "blobStoreName": "default",
      "strictContentTypeValidation": true
    },
    "docker": {
      "v1Enabled": false,
      "forceBasicAuth": true,
      "httpPort": 5000
    },
    "dockerProxy": {
      "indexType": "HUB",
      "indexUrl": "https://index.docker.io/"
    },
    "httpClient": {
      "blocked": false,
      "autoBlock": true
    },
    "proxy": {
      "remoteUrl": "https://registry-1.docker.io",
      "contentMaxAge": 1440,
      "metadataMaxAge": 1440
    },
    "negativeCache": {
      "enabled": true,
      "timeToLive": 1440
    },
    "routingRule": "docker"
  }'

echo "Docker proxy repository created"

# Create Docker group repository
curl -X POST "${NEXUS_URL}/service/rest/v1/repositories/docker/group" \
  -H "Content-Type: application/json" \
  -u "admin:nexus" \
  -d '{
    "name": "docker-group",
    "online": true,
    "storage": {
      "blobStoreName": "default",
      "strictContentTypeValidation": true
    },
    "docker": {
      "v1Enabled": false,
      "forceBasicAuth": true,
      "httpPort": 5000
    },
    "group": {
      "memberNames": [
        "docker-hosted",
        "docker-proxy"
      ]
    }
  }'

echo "Docker group repository created"

echo "Nexus initial configuration completed!"