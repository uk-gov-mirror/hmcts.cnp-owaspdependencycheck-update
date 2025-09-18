#!/bin/bash

# OWASP Dependency Check Update Script
# This script includes the necessary parameters to successfully update the dependency check database

set -e  # Exit on any error

# Required environment variables
: ${DB_PASSWORD:?"DB_PASSWORD environment variable is required"}
: ${NVD_API_KEY:?"NVD_API_KEY environment variable is required"}

# Optional environment variables with defaults
DB_HOST=${DB_HOST:-"owaspdependency-prod.postgres.database.azure.com"}
DB_NAME=${DB_NAME:-"owaspdependencycheck"}
DB_USER=${DB_USER:-"pgadmin"}
BUILD_FILE=${BUILD_FILE:-"build-v10.gradle"}
NVD_API_DELAY=${NVD_API_DELAY:-"4000"}
MAX_HEAP=${MAX_HEAP:-"3g"}

echo "Starting OWASP Dependency Check database update..."
echo "Database: ${DB_HOST}/${DB_NAME}"
echo "User: ${DB_USER}"
echo "NVD API Delay: ${NVD_API_DELAY}ms"

# Execute the gradle task with all necessary parameters
./gradlew \
  --build-file "${BUILD_FILE}" \
  --info \
  -DfailBuild='true' \
  -Dcve.check.validforhours=24 \
  -Ddata.driver_name=org.postgresql.Driver \
  -Ddata.connection_string="jdbc:postgresql://${DB_HOST}/${DB_NAME}" \
  -Ddata.user="${DB_USER}" \
  -Dnvd.api.key="${NVD_API_KEY}" \
  -Dnvd.api.delay="${NVD_API_DELAY}" \
  -Ddata.password="${DB_PASSWORD}" \
  -Ddatabase.batchinsert.enabled=true \
  -Dorg.gradle.jvmargs="-Xmx${MAX_HEAP}" \
  dependencyCheckUpdate

echo "OWASP Dependency Check database update completed successfully!"