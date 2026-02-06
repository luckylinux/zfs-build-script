#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v zfssourcepath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); zfssourcepath=$(realpath --canonicalize-missing ${scriptpath}/${relativepath}); fi

# Load Configuration
source "${zfssourcepath}/config.sh"

# Load Functions
source "${zfssourcepath}/functions.sh"

# Install Requirements
sudo apt --no-install-recommends install dkms
sudo apt install dh-dkms
sudo apt install aptitude libcurl4-openssl-dev libpam0g-dev lsb-release build-essential autoconf automake libtool libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev python3 python3-dev python3-setuptools python3-cffi libffi-dev python3-packaging git libcurl4-openssl-dev debhelper-compat dh-python po-debconf python3-all-dev python3-sphinx
sudo apt install build-essential autoconf automake libtool gawk fakeroot libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev python3 python3-dev python3-setuptools python3-cffi libffi-dev python3-packaging git libcurl4-openssl-dev debhelper-compat dh-python po-debconf python3-all-dev python3-sphinx
sudo apt install libtirpc-dev libtirpc

# Create Build Folder if it doesn't exist yet
mkdir -p "${zfssourcepath}/${zfs_build_subfolder}"

# Change to Build Folder
cd "${zfssourcepath}/${zfs_build_subfolder}"

# Use git and clone zfs-${zfs_version} tag
# git clone https://github.com/openzfs/zfs.git --depth 1 --tag zfs-${zfs_version}

# Use tar (working)
wget https://github.com/openzfs/zfs/archive/refs/tags/zfs-${zfs_version}.tar.gz -O zfs-${zfs_version}.tar.gz
mkdir -p zfs-${zfs_version}
tar xvf zfs-${zfs_version}.tar.gz -C zfs-${zfs_version} --strip-components 1

# Use tar (currently broken archive)
# wget https://github.com/openzfs/zfs/releases/download/zfs-${zfs_version}/zfs-${zfs_version}.tar.gz -O zfs-${zfs_version}.tar.gz
# tar xvf zfs-${zfs_version}.tar.gz

# Change working direectory
cd zfs-${zfs_version}

# Build ZFS
sh autogen.sh
./configure
make -s -j$(nproc)
make native-deb
make native-deb-utils native-deb-dkms

# Create Folder for Selected Packages if it doesn't exist already
mkdir -p "${zfssourcepath}/${zfs_selected_subfolder}/${zfs_version}"

# Select Subset of Packages to prevent installation of default linux-image and linux-headers
cd "${zfssourcepath}/${zfs_selected_subfolder}/${zfs_version}"

move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libnvpair3_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libpam-zfs_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libuutil3_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzfs4_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzfs5_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzfs6_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzfs7_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzpool5_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzpool6_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzpool7_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-zfs-dkms_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-zfs-initramfs_${zfs_version}*.deb ./
# move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-zfs-modules-*_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-zfs-zed_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-zfsutils_${zfs_version}*.deb ./

# Install DEB Packages
sudo apt install --fix-missing ./*.deb

