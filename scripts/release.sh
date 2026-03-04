#!/bin/bash
#
# Copyright 2024-2026 akam1o
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

# Release helper script for hugepages-reserve-service
# Usage: ./scripts/release.sh <version>

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.1"
    exit 1
fi

VERSION=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Preparing release $VERSION..."

# Update version in SPEC file
sed -i.bak "s/^Version:.*/Version:        $VERSION/" "$PROJECT_ROOT/rpm/hugepages-reserve-service.spec"

# Update version in Makefile
sed -i.bak "s/^VERSION = .*/VERSION = $VERSION/" "$PROJECT_ROOT/Makefile"

# Update changelog in debian/changelog
cd "$PROJECT_ROOT"
DEBIAN_VERSION="$VERSION-1"
CURRENT_DATE=$(date -R)
RPM_DATE=$(date +'%a %b %d %Y')

# Create new changelog entry
cat > debian/changelog.new << EOF
hugepages-reserve-service ($DEBIAN_VERSION) unstable; urgency=medium

  * Release version $VERSION

 -- System Administrator <admin@example.com>  $CURRENT_DATE

EOF

# Append existing changelog
if [ -f debian/changelog ]; then
    cat debian/changelog >> debian/changelog.new
fi
mv debian/changelog.new debian/changelog

# Update RPM changelog
sed -i.bak "s/^\* .* System Administrator.*/\* $RPM_DATE System Administrator <admin@example.com> - $VERSION-1/" "$PROJECT_ROOT/rpm/hugepages-reserve-service.spec"

# Clean up backup files
rm -f rpm/hugepages-reserve-service.spec.bak Makefile.bak

echo "Updated files:"
echo "- rpm/hugepages-reserve-service.spec"
echo "- Makefile"
echo "- debian/changelog"
echo ""
echo "Next steps:"
echo "1. Review changes: git diff"
echo "2. Commit changes: git add -A && git commit -m 'Release $VERSION'"
echo "3. Create and push tag: git tag v$VERSION && git push origin v$VERSION"
echo "4. GitHub Actions will automatically build and create release"
