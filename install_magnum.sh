#/bin/bash

# This script will download/compile the latest magnum in ~/src/gnuradio/, and install it to ~/local/
if [[ -z "$(which brew)" ]]; then
    echo "ERROR: You need to have installed Homebrew!"
    exit 1
fi

prefix=~/local
src=~/src/magnum
CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_INSTALL_RPATH=$prefix/lib"
for feature in SDL2APPLICATION AUDIO BULLET TGAIMPORTER WAVAUDIOIMPORTER DISTANCEFIELDCONVERTER OBJIMPORTER; do
    CMAKE_FLAGS="$CMAKE_FLAGS -DWITH_$feature=ON"
done

# Bring in our common tools
source common.sh

# Install some prerequisites
brew install git cmake sdl2 bullet freetype qt

# First, clone and update all repositories
mkdir -p $src; cd $src
clone_and_pull magnum https://github.com/mosra/magnum.git
clone_and_pull corrade https://github.com/mosra/corrade.git
clone_and_pull magnum-plugins https://github.com/mosra/magnum-plugins.git
clone_and_pull magnum-integration https://github.com/mosra/magnum-integration.git
clone_and_pull magnum-examples https://github.com/mosra/magnum-examples.git

# These don't really install like the others, let's just ignore them for now
#clone_and_pull magnum-extras https://github.com/mosra/magnum-extras.git
#clone_and_pull magnum-inspector https://github.com/wivlaro/magnum-inspector.git


# Start off by compiling corrade and magnum
do_cmake_build "$src/corrade"
do_cmake_build "$src/magnum"

# Now, compile integration and plugins
do_cmake_build "$src/magnum-integration"

OLD_CMAKE_FLAGS=$CMAKE_FLAGS
for plugin in ANYAUDIOIMPORTER ANYIMAGECONVERTER ANYSCENEIMPORTER COLLADAIMPORTER HARFBUZZFONT JPEGIMPORTER OPENGEXIMPORTER PNGIMPORTER STANFORDIMPORTER STBIMAGEIMPORTER STBPNGIMAGECONVERTER STBVORBISAUDIOIMPORTER; do
    CMAKE_FLAGS="$CMAKE_FLAGS -DWITH_${plugin}=ON"
done
do_cmake_build "$src/magnum-plugins"
CMAKE_FLAGS=$OLD_CMAKE_FLAGS

# Finish up with the examples
for plugin in AUDIO BULLET CUBEMAP MOTIONBLUR PICKING PRIMITIVES TEXT TEXTUREDTRIANGLE TRIANLGE VIEWER; do
    CMAKE_FLAGS="$CMAKE_FLAGS -DWITH_${plugin}_EXAMPLE=ON"
done
do_cmake_build "$src/magnum-examples"
