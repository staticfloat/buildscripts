#/bin/bash

# This script will download/compile the latest gnuradio in ~/src/gnuradio/, and install it to ~/local/

if [[ -z "$(which brew)" ]]; then
    echo "ERROR: You need to have installed Homebrew!"
    exit 1
fi

prefix=~/local
src=~/src/magnum
SKIP_CMAKE_CONFIRMATION="yes"
CMAKE_FLAGS="-DWITH_SDL2APPLICATION=ON -DWITH_AUDIO=ON -DWITH_BULLET=ON -DCMAKE_INSTALL_PREFIX=$prefix"

# Bring in our common tools
source common.sh

# Install some prerequisites
brew install git cmake sdl2 bullet freetype

# First, clone and update all repositories
mkdir -p $src; cd $src
clone_and_pull magnum https://github.com/mosra/magnum.git
clone_and_pull corrade https://github.com/mosra/corrade.git
clone_and_pull magnum-plugins https://github.com/mosra/magnum-plugins.git
clone_and_pull magnum-integration https://github.com/mosra/magnum-integration.git
clone_and_pull magnum-examples https://github.com/mosra/magnum-examples.git
#clone_and_pull magnum-extras https://github.com/mosra/magnum-extras.git
#clone_and_pull magnum-inspector https://github.com/wivlaro/magnum-inspector.git


# Start off by compiling corrade and magnum
do_cmake_build "$src/corrade"
do_cmake_build "$src/magnum"

# Now, compile integration and plugins
do_cmake_build "$src/magnum-integration"
for plugin in ANYAUDIOIMPORTER ANYIMAGECONVERTER ANYSCENEIMPORTER COLLADAIMPORTER HARFBUZZFONT JPEGIMPORTER OPENGEXIMPORTER PNGIMPORTER STANFORDIMPORTER STBIMAGEIMPORTER STBPNGIMAGECONVERTER STBVORBISAUDIOIMPORTER; do
    CMAKE_FLAGS="$CMAKE_FLAGS -DWITH_$plugin=ON"
done
do_cmake_build "$src/magnum-plugins"

# Finish up with the examples
for plugin in BULLET CUBEMAP MOTIONBLUR PICKING PRIMITIVES TEXT TEXTUREDTRIANGLE TRIANLGE VIEWER; do
    CMAKE_FLAGS="$CMAKE_FLAGS -DWITH_$plugin=ON"
done
do_cmake_build "$src/magnum-examples"
