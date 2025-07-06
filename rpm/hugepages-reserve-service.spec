Name:           hugepages-reserve-service
Version:        1.0.0
Release:        1%{?dist}
Summary:        Service for reserving hugepages on NUMA nodes

License:        GPL
URL:            https://github.com/example/hugepages-reserve-service
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       /bin/sh

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
%systemd_post hugepages-reserve.service

%preun
%systemd_preun hugepages-reserve.service

%postun
%systemd_postun_with_restart hugepages-reserve.service

%files
%config(noreplace) /etc/hugepages.conf
/usr/lib/systemd/system/hugepages-reserve.service
%attr(0755,root,root) /usr/lib/systemd/hugepages-reserve.sh

%changelog
* Fri Jul 05 2024 akam1o <admin@example.com> - 1.0.0-1
- Initial package
