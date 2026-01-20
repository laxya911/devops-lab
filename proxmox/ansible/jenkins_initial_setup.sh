#!/bin/bash
# Jenkins Initial Configuration Script
# This script configures Jenkins after startup

set -e

JENKINS_URL="http://localhost:8080"
JENKINS_HOME="/var/jenkins_home"
PLUGINS_FILE="/tmp/plugins.txt"
JCASC_FILE="/tmp/jenkins_initial_conf.yml"

# Wait for Jenkins to be ready
echo "Waiting for Jenkins to be ready..."
while ! curl -s -f "${JENKINS_URL}/api/json" > /dev/null; do
  echo "Jenkins not ready yet, waiting..."
  sleep 10
done

echo "Jenkins is ready!"

# Get initial admin password
ADMIN_PASSWORD_FILE="${JENKINS_HOME}/secrets/initialAdminPassword"
if [ -f "$ADMIN_PASSWORD_FILE" ]; then
  ADMIN_PASSWORD=$(cat "$ADMIN_PASSWORD_FILE")
else
  echo "Admin password file not found at $ADMIN_PASSWORD_FILE"
  exit 1
fi

echo "Initial admin password: $ADMIN_PASSWORD"

# Create admin user and configure security using JCasC
# First, install JCasC plugin
echo "Installing JCasC plugin..."
curl -X POST "${JENKINS_URL}/pluginManager/installPlugins" \
  -u "admin:$ADMIN_PASSWORD" \
  --data "plugin.configuration-as-code@latest"

# Wait for plugin installation
sleep 30

# Install other plugins
if [ -f "$PLUGINS_FILE" ]; then
  echo "Installing plugins from $PLUGINS_FILE..."
  while IFS= read -r plugin; do
    if [[ $plugin =~ ^[^#].* ]]; then
      plugin_name=$(echo "$plugin" | cut -d':' -f1)
      echo "Installing plugin: $plugin_name"
      curl -X POST "${JENKINS_URL}/pluginManager/installPlugins" \
        -u "admin:$ADMIN_PASSWORD" \
        --data "plugin.${plugin_name}@latest"
    fi
  done < "$PLUGINS_FILE"
fi

# Wait for plugins to install
sleep 60

# Apply JCasC configuration
if [ -f "$JCASC_FILE" ]; then
  echo "Applying JCasC configuration..."
  curl -X POST "${JENKINS_URL}/configuration-as-code/apply" \
    -u "admin:$ADMIN_PASSWORD" \
    -H "Content-Type: application/yaml" \
    --data-binary "@$JCASC_FILE"
fi

# Restart Jenkins to apply changes
echo "Restarting Jenkins..."
curl -X POST "${JENKINS_URL}/safeRestart" \
  -u "jenkins_admin:jenkins"

echo "Jenkins initial configuration completed!"