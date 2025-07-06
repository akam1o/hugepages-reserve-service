# hugepages-reserve-service

A systemd service for reserving hugepages on NUMA nodes based on configuration. Supports 2MB and 1GB hugepages with per-node configuration.

## Overview

This service reads configuration from `/etc/hugepages.conf` and reserves the specified amount of hugepages on each NUMA node during system startup.

## Configuration

Edit `/etc/hugepages.conf` to specify hugepage reservations:

```
# [node]	[hugepage_size]	[hugepage_reserve_gb]
# Example:
node0	2M	128
node1	1G	64
```

## Installation

### Manual Installation

1. Copy files to their destinations:
   ```bash
   sudo cp hugepages-reserve-service/etc/hugepages.conf /etc/
   sudo cp hugepages-reserve-service/etc/systemd/system/hugepages-reserve.service /usr/lib/systemd/system/
   sudo cp hugepages-reserve-service/usr/lib/systemd/hugepages-reserve.sh /usr/lib/systemd/
   sudo chmod +x /usr/lib/systemd/hugepages-reserve.sh
   ```

2. Enable and start the service:
   ```bash
   sudo systemctl enable hugepages-reserve.service
   sudo systemctl start hugepages-reserve.service
   ```

### Package Installation

#### Building RPM Package

1. Install build dependencies:
   ```bash
   make install-deps-rpm
   ```

2. Build the RPM package:
   ```bash
   make rpm
   ```

3. Install the package:
   ```bash
   sudo rpm -ivh ~/rpmbuild/RPMS/noarch/hugepages-reserve-service-1.0.0-1.*.noarch.rpm
   ```

#### Building DEB Package

1. Install build dependencies:
   ```bash
   make install-deps-deb
   ```

2. Build the DEB package:
   ```bash
   make deb
   ```

3. Install the package:
   ```bash
   sudo dpkg -i ../hugepages-reserve-service_1.0.0-1_all.deb
   ```

#### Building Both Packages

```bash
make all
```

## Usage

1. Configure hugepage reservations in `/etc/hugepages.conf`
2. Enable the service: `sudo systemctl enable hugepages-reserve.service`
3. The service will run automatically at system startup
4. To manually trigger hugepage reservation: `sudo systemctl start hugepages-reserve.service`

## Package Files

### RPM Package Files
- `rpm/hugepages-reserve-service.spec` - RPM package specification

### DEB Package Files  
- `debian/control` - Package metadata
- `debian/changelog` - Package change history
- `debian/rules` - Build rules
- `debian/compat` - Debhelper compatibility version
- `debian/hugepages-reserve-service.conffiles` - Configuration files
- `debian/hugepages-reserve-service.postinst` - Post-installation script
- `debian/hugepages-reserve-service.prerm` - Pre-removal script

### Build System
- `Makefile` - Build automation
- `scripts/release.sh` - Release helper script
- `.github/workflows/` - GitHub Actions CI/CD

## Development

### Creating a Release

1. Update version and create changelog:
   ```bash
   ./scripts/release.sh 1.0.1
   ```

2. Review and commit changes:
   ```bash
   git diff
   git add -A
   git commit -m "Release 1.0.1"
   ```

3. Create and push tag:
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

4. GitHub Actions will automatically:
   - Build RPM and DEB packages
   - Test package installation
   - Create GitHub release
   - Upload packages to release assets

### Manual Package Building

#### Building Both Packages

```bash
make all
```

#### Building Individual Packages

```bash
# RPM package
make install-deps-rpm  # First time only
make rpm

# DEB package  
make install-deps-deb  # First time only
make deb
```

## Installed Files

- `/etc/hugepages.conf` - Configuration file
- `/usr/lib/systemd/system/hugepages-reserve.service` - Systemd service file
- `/usr/lib/systemd/hugepages-reserve.sh` - Main script

## Requirements

- Linux system with NUMA support
- systemd
- Access to `/sys/devices/system/node/` filesystem