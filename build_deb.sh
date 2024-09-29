#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v zfssource ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); zfssourcepath=$(realpath --canonicalize-missing ${scriptpath}/${relativepath}); fi

# Install Requirements
sudo apt --no-install-recommends install dkms
sudo apt install dh-dkms
sudo apt install aptitude libcurl4-openssl-dev libpam0g-dev lsb-release build-essential autoconf automake libtool libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev python3 python3-dev python3-setuptools python3-cffi libffi-dev python3-packaging git libcurl4-openssl-dev debhelper-compat dh-python po-debconf python3-all-dev python3-sphinx
sudo apt install build-essential autoconf automake libtool gawk fakeroot libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev python3 python3-dev python3-setuptools python3-cffi libffi-dev python3-packaging git libcurl4-openssl-dev debhelper-compat dh-python po-debconf python3-all-dev python3-sphinx

# Define Desired Version
version="2.2.6"

#cd /usr/src
#mkdir -p zfs
#cd zfs

# Use git and clone zfs-$version tag
#git clone https://github.com/openzfs/zfs.git --depth 1 --tag zfs-$version

# Use tar (working)
wget https://github.com/openzfs/zfs/archive/refs/tags/zfs-$version.tar.gz -O zfs-$version.tar.gz
mkdir -p zfs-$version
tar xvf zfs-$version.tar.gz -C zfs-$version --strip-components 1
#
# Use tar (currently broken archive)
#wget https://github.com/openzfs/zfs/releases/download/zfs-$version/zfs-$version.tar.gz -O zfs-$version.tar.gz
#tar xvf zfs-$version.tar.gz

# Change working direectory
cd zfs-$version

# Apply Patch related to Symlink Creation Failure (ZFS 2.2.6)
wget https://raw.githubusercontent.com/robn/zfs/a9dd2cc828ccb9f2726ee5c3b16c32ca963083c3/contrib/bash_completion.d/Makefile.am -O contrib/bash_completion.d/Makefile.am

# Apply Patch in order to disable SIMD on AARC64 and Enable successfully ZFS Compile
# No longer needed on ZFS >= 2.2.6
#if [[ $(uname -m) == "aarch64" ]]
#then
#    ####wget https://raw.githubusercontent.com/chimera-linux/cports/master/main/zfs/patches/aarch64-disable-neon.patch -O aarch64-disable-neon.patch
#    wget https://gist.githubusercontent.com/luckylinux/6b3778d01e30ed1421178d2c6cac2e6f/raw/aac79a82fa087de318bb6eb147a7279660531659/aarch64-disable-neon.patch -O aarch64-disable-neon.patch
#    patch -p1 < aarch64-disable-neon.patch
#fi

sh autogen.sh
./configure
make -s -j$(nproc)
make native-deb
make native-deb-utils native-deb-dkms

# Select Subset of Packages to prevent installation of default linux-image and linux-headers
cd ..
mkdir -p selected-packages
mkdir -p selected-packages/$version
cd selected-packages/$version/
mv ../../openzfs-libnvpair3_$version*.deb ./
mv ../../openzfs-libpam-zfs_$version*.deb ./
mv ../../openzfs-libuutil3_$version*.deb ./
mv ../../openzfs-libzfs4_$version*.deb ./
mv ../../openzfs-libzpool5_$version*.deb ./
mv ../../openzfs-zfs-dkms_$version*.deb ./
mv ../../openzfs-zfs-initramfs_$version*.deb ./
#mv ../../openzfs-zfs-modules-*_$version*.deb ./
mv ../../openzfs-zfs-zed_$version*.deb ./
mv ../../openzfs-zfsutils_$version*.deb ./


sudo apt install --fix-missing ./*.deb
