PACKAGE_NAME = hugepages-reserve-service
VERSION = 1.0.0
RELEASE = 1

# RPM build directories
RPM_BUILD_DIR = $(HOME)/rpmbuild
RPM_SOURCES_DIR = $(RPM_BUILD_DIR)/SOURCES
RPM_SPECS_DIR = $(RPM_BUILD_DIR)/SPECS
RPM_RPMS_DIR = $(RPM_BUILD_DIR)/RPMS

.PHONY: all clean rpm deb prepare-rpm prepare-deb

all: rpm deb

# Prepare source tarball for RPM
prepare-rpm:
	@echo "Preparing RPM build environment..."
	@mkdir -p $(RPM_BUILD_DIR)/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
	@tar --exclude='.git' --exclude='rpm' --exclude='debian' --exclude='Makefile' \
		--exclude='*.rpm' --exclude='*.deb' --exclude='*.tar.gz' \
		-czf $(RPM_SOURCES_DIR)/$(PACKAGE_NAME)-$(VERSION).tar.gz \
		--transform 's,^,$(PACKAGE_NAME)-$(VERSION)/,' hugepages-reserve-service/
	@cp rpm/$(PACKAGE_NAME).spec $(RPM_SPECS_DIR)/

# Build RPM package
rpm: prepare-rpm
	@echo "Building RPM package..."
	rpmbuild -ba $(RPM_SPECS_DIR)/$(PACKAGE_NAME).spec
	@echo "RPM package built successfully!"
	@echo "Location: $(RPM_RPMS_DIR)/noarch/$(PACKAGE_NAME)-$(VERSION)-$(RELEASE).*.noarch.rpm"

# Build DEB package
deb:
	@echo "Building DEB package..."
	@if command -v dpkg-buildpackage >/dev/null 2>&1; then \
		dpkg-buildpackage -us -uc -b; \
	else \
		echo "dpkg-buildpackage not found. Use 'make test-deb' for Docker-based testing."; \
		exit 1; \
	fi
	@echo "DEB package built successfully!"
	@echo "Location: ../$(PACKAGE_NAME)_$(VERSION)-1_all.deb"

# Test DEB build using Docker (for macOS/Windows)
test-deb:
	@echo "Testing DEB package build using Docker..."
	@./scripts/test-deb-build.sh

# Install build dependencies
install-deps-rpm:
	@echo "Installing RPM build dependencies..."
	@if command -v dnf >/dev/null 2>&1; then \
		sudo dnf install -y rpm-build rpmdevtools; \
	elif command -v yum >/dev/null 2>&1; then \
		sudo yum install -y rpm-build rpmdevtools; \
	else \
		echo "Please install rpm-build and rpmdevtools manually"; \
	fi

install-deps-deb:
	@echo "Installing DEB build dependencies..."
	@sudo apt-get update
	@sudo apt-get install -y build-essential debhelper devscripts

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(RPM_BUILD_DIR)
	@rm -f ../$(PACKAGE_NAME)_$(VERSION)*
	@rm -f debian/files debian/.debhelper debian/hugepages-reserve-service/ debian/tmp/
	@rm -f debian/debhelper-build-stamp
	@rm -f debian/hugepages-reserve-service.debhelper.log
	@rm -f debian/hugepages-reserve-service.substvars
	@rm -rf debian/.debhelper/

# Help target
help:
	@echo "Available targets:"
	@echo "  all                - Build both RPM and DEB packages"
	@echo "  rpm                - Build RPM package"
	@echo "  deb                - Build DEB package"
	@echo "  test-deb           - Test DEB build using Docker (for macOS/Windows)"
	@echo "  install-deps-rpm   - Install RPM build dependencies"
	@echo "  install-deps-deb   - Install DEB build dependencies"
	@echo "  clean              - Clean build artifacts"
	@echo "  help               - Show this help message"
