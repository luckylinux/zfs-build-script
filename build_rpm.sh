#!/bin/bash
# Install Requirements
dnf install gcc make autoconf automake libtool rpm-build libtirpc-devel libblkid-devel libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel elfutils-libelf-devel kernel-devel-$(uname -r) python3 python3-devel python3-setuptools python3-cffi libffi-devel git ncompress libcurl-devel
dnf install bc bison flex libtirpc-devel python3-packaging dkms wget

# Define Desired Version
version="2.2.4"

cd /usr/src
mkdir -p zfs
cd zfs

# Save basedir
basedir=$(pwd)

# Use git and clone zfs-$version tag
#git clone https://github.com/openzfs/zfs.git --depth 1 --tag zfs-$version
#
# Use tar (working)
wget https://github.com/openzfs/zfs/archive/refs/tags/zfs-$version.tar.gz -O zfs-$version.tar.gz
mkdir -p zfs-$version
tar xvf zfs-$version.tar.gz -C zfs-$version --strip-components 1

# Use tar (currently broken archive)
#wget https://github.com/openzfs/zfs/releases/download/zfs-$version/zfs-$version.tar.gz -O zfs-$version.tar.gz
#tar xvf zfs-$version.tar.gz

# Change working direectory
cd zfs-$version

# Apply Patch in order to disable SIMD and Enable successfully ZFS Compile
wget https://gist.githubusercontent.com/luckylinux/6b3778d01e30ed1421178d2c6cac2e6f/raw/aac79a82fa087de318bb6eb147a7279660531659/aarch64-disable-neon.patch -O aarch64-disable-neon.patch
patch -p1 < aarch64-disable-neon.patch

sh autogen.sh
./configure
make clean

make -s -j$(nproc)
make rpm

# Select Subset of Packages to prevent installation of default linux-image and linux-headers
cd $basedir
mkdir -p selected-packages
mkdir -p selected-packages/$version
cd selected-packages/$version/
mv ../../zfs-$version/libnvpair3-$version*.aarch64.rpm ./
mv ../../zfs-$version/libuutil3-$version*.aarch64.rpm ./
mv ../../zfs-$version/libzfs5-$version*.aarch64.rpm ./
mv ../../zfs-$version/libzpool5-$version*.aarch64.rpm ./
mv ../../zfs-$version/zfs-$version*.aarch64.rpm ./
mv ../../zfs-$version/zfs-dkms-$version*.noarch.rpm ./
mv ../../zfs-$version/zfs-dracut-$version*.noarch.rpm ./
#mv ../../zfs-$version/zfs-zed_$version*.rpm ./
#mv ../../zfs-$version/zfsutils_$version*.rpm ./


#-rw-r--r--.   1 root root  1441697 Jun 25 13:45 kmod-zfs-6.8.5-301.fc40.aarch64-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root 12065958 Jun 25 13:45 kmod-zfs-6.8.5-301.fc40.aarch64-debuginfo-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root   362177 Jun 25 13:45 kmod-zfs-devel-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root    21831 Jun 25 13:45 kmod-zfs-devel-6.8.5-301.fc40.aarch64-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root    40326 Jun 25 14:04 libnvpair3-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root   116453 Jun 25 14:04 libnvpair3-debuginfo-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root    32083 Jun 25 14:04 libuutil3-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root    61062 Jun 25 14:04 libuutil3-debuginfo-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root   231595 Jun 25 14:04 libzfs5-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root   611409 Jun 25 14:04 libzfs5-debuginfo-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root   359240 Jun 25 14:04 libzfs5-devel-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root  1339048 Jun 25 14:04 libzpool5-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root  3998759 Jun 25 14:04 libzpool5-debuginfo-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root   155647 Jun 25 14:04 python3-pyzfs-2.2.4-1.fc40.noarch.rpm
#-rw-r--r--.   1 root root   744830 Jun 25 14:04 zfs-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root 34032991 Jun 25 13:48 zfs-2.2.4-1.fc40.src.rpm
#-rw-r--r--.   1 root root  1144233 Jun 25 14:04 zfs-debuginfo-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root  2275587 Jun 25 14:04 zfs-debugsource-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root 32414443 Jun 25 13:48 zfs-dkms-2.2.4-1.fc40.noarch.rpm
#-rw-r--r--.   1 root root 34021067 Jun 25 13:45 zfs-dkms-2.2.4-1.fc40.src.rpm
#-rw-r--r--.   1 root root    17349 Jun 25 14:04 zfs-dracut-2.2.4-1.fc40.noarch.rpm
#-rw-r--r--.   1 root root 34029336 Jun 25 13:32 zfs-kmod-2.2.4-1.fc40.src.rpm
#-rw-r--r--.   1 root root  1883153 Jun 25 13:45 zfs-kmod-debugsource-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root 28864649 Jun 25 14:04 zfs-test-2.2.4-1.fc40.aarch64.rpm
#-rw-r--r--.   1 root root   376301 Jun 25 14:04 zfs-test-debuginfo-2.2.4-1.fc40.aarch64.rpm




sudo dnf install ./*.rpm
