#!/bin/bash
#
# Copyright 2024-2025 akam1o
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
