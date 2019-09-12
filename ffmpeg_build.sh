#!/bin/bash
set -xe

PKG_CONFIG_PATH=/usr/lib/pkgconfig
FDK_AAC_VERSION=v0.1.6
NASM_VERSION=2.14.02

mkdir -p /usr/local/src
cd /usr/local/src

rm -r -f x264 fdk-aac FFmpeg nasm-2.14.02 x265
git clone --depth 1 git://git.videolan.org/x264.git
git clone --depth 1 --branch ${FDK_AAC_VERSION} git://github.com/mstorsjo/fdk-aac.git
git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git
git clone --depth 1 https://github.com/videolan/x265.git
#hg clone https://bitbucket.org/multicoreware/x265

# Build nasm
#curl -s http://ftp.oregonstate.edu/.1/blfs/conglomeration/nasm/nasm-${NASM_VERSION}.tar.xz | tar xJ
curl -s https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.xz | tar xJ
cd /usr/local/src/nasm-${NASM_VERSION}
./configure --prefix=/usr
make -j $(nproc)
make install

# Build libx264
cd /usr/local/src/x264
./configure --enable-pic --enable-static
make -j $(nproc)
make install
ldconfig

# Build libx265
cd /usr/local/src/x265/build/linux
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ../../source
make -j $(nproc)
make install

# Build libfdk-aac
cd /usr/local/src/fdk-aac
autoreconf -fiv
./configure --disable-shared
make -j $(nproc)
make install

# Build ffmpeg.
cd /usr/local/src/FFmpeg

./configure \
    --enable-gpl \
    --enable-libfdk-aac \
    --enable-libmp3lame \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    --extra-libs="-ldl" \
    --pkg-config-flags="--static"
make -j $(nproc)
make install

# Remove all tmpfiles
rm -rf /usr/local/src
