#/bin/bash

# This script will download/compile the latest gnuradio in ~/src/gnuradio/, and install it to ~/local/

if [[ -z "$(which brew)" ]]; then
    echo "ERROR: You need to have installed Homebrew!"
    exit 1
fi

# Install some prerequisites
brew install git cmake python

prefix=~/local
src=~/src/gnuradio

# Get our python parameters here so we can pass them explicitly in do_cmake_build
PY_EXE=$(which python)
PY_LIB=$(otool -L $(which python) | grep Python | awk '{print $1}')
PY_HEAD=$(dirname $PY_LIB)/Headers
CMAKE_FLAGS="-DPYTHON_EXECUTABLE=$PY_EXE -DPYTHON_LIBRARY=$PY_LIB -DPYTHON_INCLUDE_DIR=$PY_HEAD -DCMAKE_INSTALL_PREFIX=$prefix"

# Bring in our common tools
source common.sh

# First, clone and update all repositories
mkdir -p $src; cd $src
clone_and_pull bladeRF https://github.com/Nuand/bladeRF.git libbladeRF_v1.4.3
clone_and_pull gnuradio https://github.com/gnuradio/gnuradio.git maint
clone_and_pull uhd https://github.com/EttusResearch/uhd.git release_003_009_001
clone_and_pull gr-ieee802-11 https://github.com/bastibl/gr-ieee802-11.git
clone_and_pull gr-osmosdr git://git.osmocom.org/gr-osmosdr.git
clone_and_pull gr-fosphor git://git.osmocom.org/gr-fosphor.git
clone_and_pull gr-foo https://github.com/bastibl/gr-foo.git


# Start off by compiling uhd and bladeRF
brew install boost libusb
pip install cheetah mako
do_cmake_build "$src/uhd/host"


do_cmake_build "$src/bladeRF/host"

# Now, compile gnuradio installing dependencies as needed
brew install wxpython pygtk
brew install zeromq swig fftw orc
pip install pyzmq lxml numpy
do_cmake_build "$src/gnuradio"


# Now that we've got gnuradio, let's do gr-osmosdr, gr-foo and then gr-ieee802-11
do_cmake_build "$src/gr-osmosdr"


brew install cppunit
do_cmake_build "$src/gr-foo"


brew install itpp log4cpp
do_cmake_build "$src/gr-ieee802-11"


# Let's try gr-fosphor just for function
pip install pyopengl
do_cmake_build "$src/gr-fosphor"
