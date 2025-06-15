#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v zfssourcepath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); zfssourcepath=$(realpath --canonicalize-missing ${scriptpath}/${relativepath}); fi

# Load Configuration
source "${zfssourcepath}/config.sh"

# Load Functions
source "${zfssourcepath}/functions.sh"

# Decide which Build to perform
if [[ $(command -v dpkg) ]]
then
    # Use DEB Build Script
    source build_deb.sh
elif [[ $(command -v zfs) ]]
then
    # Use RPM Build Script
    source build_rpm.sh
fi
