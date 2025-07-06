#!/bin/bash

# Local DEB package test using Docker
# This script allows testing DEB package building on macOS/Windows

set -e

echo "Testing DEB package build using Docker..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is required for local DEB testing"
    exit 1
fi

# Build in Ubuntu container
docker run --rm -v "$(pwd)":/workspace -w /workspace ubuntu:22.04 bash -c "
    apt-get update
    apt-get install -y build-essential debhelper devscripts
    chmod +x debian/rules
    dpkg-buildpackage -us -uc -b
"

echo "DEB package built successfully!"
echo "Package location: ../hugepages-reserve-service_*.deb"
