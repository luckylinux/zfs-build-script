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

# Apply Patch related to Symlink Creation Failure (ZFS 2.2.6)
wget https://raw.githubusercontent.com/robn/zfs/a9dd2cc828ccb9f2726ee5c3b16c32ca963083c3/contrib/bash_completion.d/Makefile.am -O contrib/bash_completion.d/Makefile.am

# Apply Patch in order to disable SIMD on AARC64 and Enable successfully ZFS Compile
# No longer needed on ZFS >= 2.2.6
# if [[ $(uname -m) == "aarch64" ]]
# then
#     ####wget https://raw.githubusercontent.com/chimera-linux/cports/master/main/zfs/patches/aarch64-disable-neon.patch -O aarch64-disable-neon.patch
#     wget https://gist.githubusercontent.com/luckylinux/6b3778d01e30ed1421178d2c6cac2e6f/raw/aac79a82fa087de318bb6eb147a7279660531659/aarch64-disable-neon.patch -O aarch64-disable-neon.patch
#     patch -p1 < aarch64-disable-neon.patch
# fi

sh autogen.sh
./configure
make -s -j$(nproc)
make native-deb
make native-deb-utils native-deb-dkms

# Select Subset of Packages to prevent installation of default linux-image and linux-headers
cd "${zfssourcepath}"
mkdir -p "${zfssourcepath}/${zfs_selected_subfolder}/${zfs_version}"

cd "${zfssourcepath}/${zfs_selected_subfolder}/${zfs_version}"

move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libnvpair3_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libpam-zfs_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libuutil3_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzfs4_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzfs5_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzfs6_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzpool5_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-libzpool6_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-zfs-dkms_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-zfs-initramfs_${zfs_version}*.deb ./
# move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-zfs-modules-*_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-zfs-zed_${zfs_version}*.deb ./
move_file ${zfssourcepath}/${zfs_build_subfolder}/openzfs-zfsutils_${zfs_version}*.deb ./

# Install DEB Packages
sudo apt install --fix-missing ./*.deb

