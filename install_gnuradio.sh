#/bin/bash

# This script will download/compile the latest gnuradio in ~/src/gnuradio/, and install it to ~/local/

# Bring in our common tools
source common.sh

# Install some prerequisites
pkg_install git cmake python

prefix=~/local
src=~/src/gnuradio

# Get our python parameters and tack them onto the end of CMAKE_FLAGS
PY_EXE=$(which python)
CMAKE_FLAGS="-DPYTHON_EXECUTABLE=$PY_EXE"

# If we're running on OSX, add in these Python flags so we don't pick up Homebrew Python or somesuch
if [[ $(uname -s) == "Darwin" ]]; then
    PY_LIB=$(otool -L $(which python) | grep Python | awk '{print $1}')
    PY_HEAD=$(dirname $PY_LIB)/Headers
    CMAKE_FLAGS="$CMAKE_FLAGS -DPYTHON_LIBRARY=$PY_LIB -DPYTHON_INCLUDE_DIR=$PY_HEAD"
fi
CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_INSTALL_PREFIX=$prefix"

# First, clone and update all repositories
mkdir -p $src; cd $src
clone_and_pull bladeRF https://github.com/Nuand/bladeRF.git libbladeRF_v1.6.1
clone_and_pull gnuradio https://github.com/gnuradio/gnuradio.git
clone_and_pull uhd https://github.com/EttusResearch/uhd.git release_003_009_001
clone_and_pull gr-osmosdr git://git.osmocom.org/gr-osmosdr.git

# These are highly optional, I just include them 'cause they're awesome.
clone_and_pull gr-fosphor git://git.osmocom.org/gr-fosphor.git
clone_and_pull gr-foo https://github.com/bastibl/gr-foo.git
clone_and_pull gr-ieee802-11 https://github.com/bastibl/gr-ieee802-11.git
clone_and_pull gr-ieee802-15-4 https://github.com/bastibl/gr-ieee802-15-4.git

# Start off by compiling uhd and bladeRF
pkg_install boost libusb
pip_install cheetah mako
do_cmake_build "$src/uhd/host" $CMAKE_FLAGS
do_cmake_build "$src/bladeRF/host" $CMAKE_FLAGS

# Now, compile gnuradio installing dependencies as needed
pkg_install wxpython pygtk
pkg_install zeromq swig fftw orc
pip_install pyzmq lxml numpy
do_cmake_build "$src/gnuradio" $CMAKE_FLAGS


# Now that we've got gnuradio, let's do gr-osmosdr, gr-foo and then gr-ieee802-11
# Note that these are highly optional and I only include them because they are awesome.
pkg_install cppunit itpp log4cpp librtlsdr
do_cmake_build "$src/gr-osmosdr" $CMAKE_FLAGS
do_cmake_build "$src/gr-foo" $CMAKE_FLAGS
do_cmake_build "$src/gr-ieee802-11" $CMAKE_FLAGS
do_cmake_build "$src/gr-ieee802-15-4" $CMAKE_FLAGS

# I can't live without my beautiful fosphor
CMAKE_FLAGS="$CMAKE_FLAGS -DFREETYPE2_INCLUDE_DIRS=/usr/local/include/freetype2/ -DFREETYPE2_FOUND=True -DFREETYPE2_LIBRARIES=-lfreetype"
if [[ $(uname -s) == "Linux" ]]; then
    pkg_install libgl1-mesa-dev
fi
pip_install pyopengl
do_cmake_build "$src/gr-fosphor" $CMAKE_FLAGS
