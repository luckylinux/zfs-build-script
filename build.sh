#!/bin/bash
# Install Requirements
sudo apt-get --no-install-recommends install dkms
sudo apt-get install dh-dkms
sudo apt-get install aptitude libcurl4-openssl-dev libpam0g-dev lsb-release build-essential autoconf automake libtool libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev python3 python3-dev python3-setuptools python3-cffi libffi-dev python3-packaging git libcurl4-openssl-dev debhelper-compat dh-python po-debconf python3-all-dev python3-sphinx
sudo apt-get install build-essential autoconf automake libtool gawk fakeroot libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev python3 python3-dev python3-setuptools python3-cffi libffi-dev python3-packaging git libcurl4-openssl-dev debhelper-compat dh-python po-debconf python3-all-dev python3-sphinx
sudo apt-get install linux-headers-generic
sudo apt-get install bc bison flex libtirpc-dev

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
#wget https://raw.githubusercontent.com/chimera-linux/cports/master/main/zfs/patches/aarch64-disable-neon.patch -O aarch64-disable-neon.patch
#patch -p1 < aarch64-disable-neon.patch

sh autogen.sh
./configure
make clean

# Must exclude python3
#zfs-2.2.3/contrib/debian/control:         python3-distutils | libpython3-stdlib (<< 3.6.4),
#zfs-2.2.3/debian/openzfs-zfs-dkms/DEBIAN/control:Depends: dkms (>> 2.1.1.2-5), file, libc6-dev | libc-dev, lsb-release, python3-distutils | libpython3-stdlib (<< 3.6.4), debconf (>= 0.5) | debconf-2.0, perl:any
#zfs-2.2.3/debian/control:         python3-distutils | libpython3-stdlib (<< 3.6.4),

#sed -Ei "/s/,\s*?python3-distutils.*?,/,/g" contrib/debian/control
#sed -Ei "/s/,\s*?python3-distutils.*?,/,/g" debian/openzfs-zfs-dkms/DEBIAN/control
#sed -Ei "/s/,\s*?python3-distutils.*?,/,/g" debian/control

#regexcmd="s/,\s*?python3-distutils\s*?|\s*?libpython3-stdlib \(.*?\),//g"
#sed -Ei ${regexcmd} contrib/debian/control
#sed -Ei ${regexcmd} debian/openzfs-zfs-dkms/DEBIAN/control
#sed -Ei ${regexcmd} debian/control

#sed -Ei "s/, python3-distutils | libpython3-stdlib (<< 3.6.4), /, /g" ./debian/openzfs-zfs-dkms/DEBIAN/control
#sed -Ei "s/python3-distutils | libpython3-stdlib (<< 3.6.4),//g" ./contrib/debian/control
#sed -Ei "s/python3-distutils | libpython3-stdlib (<< 3.6.4),//g" ./debian/control

make -s -j$(nproc)
make native-deb
make native-deb-utils native-deb-dkms

# Select Subset of Packages to prevent installation of default linux-image and linux-headers
cd $basedir
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
mv ../../openzfs-zfs-zed_$version*.deb ./
mv ../../openzfs-zfsutils_$version*.deb ./


sudo apt-get install --fix-missing ./*.deb
