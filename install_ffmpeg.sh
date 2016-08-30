#!/bin/bash

# Bring in common tools
source common.sh

PREFIX="$(echo ~)/local"

clone_and_pull ~/src/libx264 git://git.videolan.org/x264
clone_and_pull ~/src/libvpx https://chromium.googlesource.com/webm/libvpx
clone_and_pull ~/src/ffmpeg https://github.com/FFmpeg/FFmpeg.git master

do_autoconf_build ~/src/libx264 --prefix=$PREFIX --enable-static
do_autoconf_build ~/src/libvpx --prefix=$PREFIX --enable-static
do_autoconf_build ~/src/ffmpeg --prefix=$PREFIX --enable-libx264 --enable-libvpx --enable-gpl --enable-nonfree
