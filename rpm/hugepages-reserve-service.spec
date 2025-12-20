Name:           hugepages-reserve-service
Version:        1.0.5
Release:        1%{?dist}
Summary:        Service for reserving hugepages on NUMA nodes

License:        Apache-2.0
URL:            https://github.com/example/hugepages-reserve-service
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       /bin/sh
# systemd is recommended but not strictly required
%if 0%{?rhel} >= 7 || 0%{?fedora} >= 15
Recommends:     systemd
%endif

%description
A systemd service for reserving hugepages on NUMA nodes based on configuration.
Supports 2MB and 1GB hugepages with per-node configuration.

%prep
%setup -q

%build
# No build needed for shell scripts

%install
rm -rf $RPM_BUILD_ROOT

# Create directory structure
mkdir -p $RPM_BUILD_ROOT/etc
mkdir -p $RPM_BUILD_ROOT/usr/lib/systemd/system
mkdir -p $RPM_BUILD_ROOT/usr/lib/systemd

# Install files
cp -p hugepages-reserve-service/etc/hugepages.conf $RPM_BUILD_ROOT/etc/
cp -p hugepages-reserve-service/etc/systemd/system/hugepages-reserve.service $RPM_BUILD_ROOT/usr/lib/systemd/system/
cp -p hugepages-reserve-service/usr/lib/systemd/hugepages-reserve.sh $RPM_BUILD_ROOT/usr/lib/systemd/

%post
if [ $1 -eq 1 ] ; then
    # Initial installation
    if command -v systemctl >/dev/null 2>&1; then
        systemctl preset hugepages-reserve.service >/dev/null 2>&1 || :
    fi
fi

%preun
if [ $1 -eq 0 ] ; then
    # Package removal, not upgrade
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --no-reload disable hugepages-reserve.service >/dev/null 2>&1 || :
        systemctl stop hugepages-reserve.service >/dev/null 2>&1 || :
    fi
fi

%postun
if command -v systemctl >/dev/null 2>&1; then
    systemctl daemon-reload >/dev/null 2>&1 || :
fi
if [ $1 -ge 1 ] ; then
    # Package upgrade, not uninstall
    if command -v systemctl >/dev/null 2>&1; then
        systemctl try-restart hugepages-reserve.service >/dev/null 2>&1 || :
    fi
fi

%files
%config(noreplace) /etc/hugepages.conf
/usr/lib/systemd/system/hugepages-reserve.service
%attr(0755,root,root) /usr/lib/systemd/hugepages-reserve.sh

%changelog
* Fri Jul 05 2024 akam1o <admin@example.com> - 1.0.0-1
- Initial package
