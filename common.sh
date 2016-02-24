#!/bin/bash

function confirm
{
    read -p "Does this look okay? [y/n] "
    [[ $REPLY =~ ^[Yy]$ ]]
    return
}


# Usage: do_cmake_build [source_folder]
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

# Usage: clone_and_pull <folder_name> <clone_url> [branch]
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

function pkg_install_error_msg
{
	cat <<-EOF
		ERROR: $1 not found, highly recommended in order to use this script!
		If you will not/cannot use a package manager I understand, then run:

		`export SKIP_DEPENDENCY_INSTALLATION=yes`

		before running this script to skip all library installations.
		You will have to install all dependencies manually. Look for lines that
		say 'Explicitly skipping dependency installation of <foo>' to see what
		external dependencies are needed on your system.
	EOF
}

# Usage: pkg_install <pkg1> [pkg2...]
function pkg_install
{
	# If the user is explicitly asking us to skip this, then skip it!
    if [[ ! -z "$SKIP_DEPENDENCY_INSTALLATION" ]]; then
		echo "Explicitly skipping dependency installation of $*"
        return
    fi

    # Figure out our platform, and whether we have the right tools
    OS_NAME=$(uname -s)
    if [[ "$OS_NAME" == "Darwin" ]]; then
        if [[ -z $(which brew) ]]; then
			pkg_install_error_msg "brew"
			echo "You can install Homebrew from http://brew.sh"
			exit
        fi

		brew install $*
	elif [[ "$OS_NAME" == "Linux" ]]; then
		if [[ ! -z $(apt-get) ]]; then
			sudo apt-get install -y $*
		elif [[ ! -z $(yum) ]]; then
			sudo yum install -y $*
		else
			pkg_install_error_msg "package manager"
			exit
		fi
	else
		pkg_install_error_msg "supported OS"
		exit
    fi
}
