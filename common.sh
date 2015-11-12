#!/bin/bash

function confirm
{
    read -p "Does this look okay? [y/n] "
    [[ $REPLY =~ ^[Yy]$ ]]
    return
}


function do_cmake_build
{
    if [[ ! -z "$1" ]]; then
        cd "$1"
    fi
    if [[ ! -d build ]]; then
        mkdir build
    fi
    cd build
    if [[ ! -d CMakeFiles ]]; then
        echo
        echo
        echo "Doing cmake build in $(pwd)"
        echo cmake $CMAKE_FLAGS ..
        cmake $CMAKE_FLAGS ..
        if [[ -z "$SKIP_CMAKE_CONFIRMATION" ]] && ! confirm; then
            cd ..
            rm -rf build
            exit
        fi
    fi
    make install -j4
}

function clone_and_pull
{
    if [[ ! -d "$1" ]]; then
        git clone "$2" "$1"
    fi
    if [[ ! -z "$3" ]]; then
        (cd "$1" && git checkout "$3")
    fi
    (cd "$1" && git submodule init)
    (cd "$1" && git pull --recurse-submodules)
    (cd "$1" && git submodule update --recursive)
}
