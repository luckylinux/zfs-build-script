#!/bin/bash

# Custom Move File Function (check if File exists)
move_file() {
    # Input Arguments
    local lsource="$1"
    local ldestination="$2"

    # Debug
    # echo "Source: ${lsource}"
    # echo "Destination: ${ldestination}"

    # Check if Source File exists
    if [[ -f "${lsource}" ]]
    then
        mv "${lsource}" "${ldestination}"
    fi
}
