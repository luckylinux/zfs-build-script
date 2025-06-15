#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v zfssourcepath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); zfssourcepath=$(realpath --canonicalize-missing ${scriptpath}/${relativepath}); fi

# Load Configuration
source "${zfssourcepath}/config.sh"

# Load Functions
source "${zfssourcepath}/functions.sh"

# Install Requirements
dnf install gcc make autoconf automake libtool rpm-build libtirpc-devel libblkid-devel libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel elfutils-libelf-devel kernel-devel-$(uname -r) python3 python3-devel python3-setuptools python3-cffi libffi-devel git ncompress libcurl-devel
dnf install bc bison flex libtirpc-devel python3-packaging dkms wget

# Create Build Folder if it doesn't exist yet
mkdir -p "${zfssourcepath}/${zfs_build_subfolder}"

# Change to Build Folder
cd "${zfssourcepath}/${zfs_build_subfolder}"

# Use git and clone zfs-${zfs_version} tag
# git clone https://github.com/openzfs/zfs.git --depth 1 --tag zfs-${zfs_version}
#
# Use tar (working)
wget https://github.com/openzfs/zfs/archive/refs/tags/zfs-${zfs_version}.tar.gz -O zfs-${zfs_version}.tar.gz
mkdir -p zfs-${zfs_version}
tar xvf zfs-${zfs_version}.tar.gz -C zfs-${zfs_version} --strip-components 1

# Use tar (currently broken archive)
# wget https://github.com/openzfs/zfs/releases/download/zfs-${zfs_version}/zfs-${zfs_version}.tar.gz -O zfs-${zfs_version}.tar.gz
# tar xvf zfs-${zfs_version}.tar.gz

# Change working direectory
cd zfs-${zfs_version}

# Apply Patch in order to disable SIMD and Enable successfully ZFS Compile
# No longer needed on ZFS >= 2.2.6
# if [[ $(uname -m) == "aarch64" ]]
# then
#     wget https://gist.githubusercontent.com/luckylinux/6b3778d01e30ed1421178d2c6cac2e6f/raw/aac79a82fa087de318bb6eb147a7279660531659/aarch64-disable-neon.patch -O aarch64-disable-neon.patch
#     patch -p1 < aarch64-disable-neon.patch
# fi

# Configure
sh autogen.sh
./configure
make clean

# Build
make -s -j$(nproc)
make rpm

# Create Folder for Selected Packages if it doesn't exist already
mkdir -p "${zfssourcepath}/${zfs_selected_subfolder}/${zfs_version}"

# Select Subset of Packages to prevent installation of default linux-image and linux-headers
cd "${zfssourcepath}/${zfs_selected_subfolder}/${zfs_version}"

move_file ${zfssourcepath}/${zfs_build_subfolder}/zfs-${zfs_version}/libnvpair3-${zfs_version}*.aarch64.rpm ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/zfs-${zfs_version}/libuutil3-${zfs_version}*.aarch64.rpm ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/zfs-${zfs_version}/libzfs4-${zfs_version}*.aarch64.rpm ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/zfs-${zfs_version}/libzfs5-${zfs_version}*.aarch64.rpm ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/zfs-${zfs_version}/libzfs6-${zfs_version}*.aarch64.rpm ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/zfs-${zfs_version}/libzpool5-${zfs_version}*.aarch64.rpm ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/zfs-${zfs_version}/libzpool6-${zfs_version}*.aarch64.rpm ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/zfs-${zfs_version}/zfs-${zfs_version}*.aarch64.rpm ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/zfs-${zfs_version}/zfs-dkms-${zfs_version}*.noarch.rpm ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/zfs-${zfs_version}/zfs-dracut-${zfs_version}*.noarch.rpm ./

# Install Selected Packages
sudo dnf install ./*.rpm
