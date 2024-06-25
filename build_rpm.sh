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

# Configure
sh autogen.sh
./configure
make clean

# Build
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

# Install Selected Packages
sudo dnf install ./*.rpm
