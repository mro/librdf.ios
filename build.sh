#!/bin/bash
# Copyright (c) 2014, Marcus Rohrmoser mobile Software
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted
# provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions
#    and the following disclaimer.
#
# 2. The software must not be used for military or intelligence or related purposes nor
#    anything that's in conflict with human rights as declared in http://www.un.org/en/documents/udhr/ .
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

#
# Cross compile 3 C libs. Called from Xcode via env -i
#
# Inspired by the process & settings applied by
# https://github.com/p2/Redland-ObjC/blob/bf123466ae308018b189c05ea39b6b877a083a54/Redland-source/cross-compile.py
#

RAPTOR=raptor2-2.0.14
RASQAL=rasqal-0.9.32
REDLAND=redland-1.0.17

max_cores=8

if [ "$1" = "" ] || [ "$1" = "help" ] ; then
  cat <<HELP_MESSAGE
Download and cross-compile (on max. $max_cores CPU cores):

  $RAPTOR, $RASQAL, $REDLAND

for

  Mac-i386 Mac-x86_64 iOS-armv7 iOS-armv7s iOS-arm64

Usage:

  $0 help           # this screen
  $0 all            # download, configure, make, lipo.
  $0 clean          # remove all created artifacts (but keep downloads)

HELP_MESSAGE
  exit 0
fi

cd "$(dirname "$0")"
cwd=$(pwd)
# echo $$ start $@

tarball_base_dir=tarballs
sources_base_dir=src
build_base_dir=build

if [ "$1" = "clean" ] ; then
  set -x
  rm -rf "$sources_base_dir" "$build_base_dir"
  set +x
  exit 0
fi

###########################################################
#### check preliminaries
###########################################################
which curl        >/dev/null 2>&1 || { echo "curl is not installed." && exit 1; }
which xargs       >/dev/null 2>&1 || { echo "xargs is not installed." && exit 1; }
which tar         >/dev/null 2>&1 || { echo "tar is not installed." && exit 1; }
which make        >/dev/null 2>&1 || { echo "make is not installed - I guess Xcode commandline tools are missing." && exit 1; }
which lipo        >/dev/null 2>&1 || { echo "lipo is not installed - I guess Xcode commandline tools are missing." && exit 1; }
which pkg-config  >/dev/null 2>&1 || { echo "pkg-config is not installed - consider $ brew install pkg-config" && exit 1; }


###########################################################
#### download
###########################################################
for lib in $RAPTOR $RASQAL $REDLAND
do
  tarball="$tarball_base_dir/$lib.tar.gz"
  if [ ! -f "$tarball" ] ; then
    set -x
    curl --create-dirs --location --output "$tarball" --url "http://download.librdf.org/source/$lib.tar.gz"
    set +x
  fi
done

###########################################################
#### build all in parallel (call myself via xargs)
###########################################################
if [ "$1" = "all" ] ; then
  for lib in $RAPTOR $RASQAL $REDLAND
  do
    echo "$$ building $lib"
    params=""
    for platform in Mac-i386 Mac-x86_64 iOS-armv7 iOS-armv7s iOS-arm64 ; do
      params="$params $platform $lib"
    done
    # call myself with 2 parameters each (platform,lib) in up to $max_cores parallel processes
    echo "$params" | xargs -P $max_cores -n 2 sh "$(basename "$0")"
  done

  #### bundle libraries
  for lib in libraptor2.a librasqal.a librdf.a
  do
    if [ ! -f "$build_base_dir/$lib" ] ; then
      set -x
      lipo -create -output "$build_base_dir/$lib" $(ls "$build_base_dir/"*"/lib/$lib") || { exit $?; }
      set +x
    fi
  done
  ls -l "$build_base_dir/"*"/include/redland.h" "$build_base_dir/"*.a

  # echo $$ finish $@
  exit 0
fi

###########################################################
#### build exactly one
###########################################################
if [ "$2" = "" ] || [ "$3" != "" ] ; then
  echo "I expect 2 parameters - platform and lib"
  exit 1
fi
platform="$1"
lib="$2"

###########################################################
#### unpack tarball if necessary
###########################################################
tarball="$tarball_base_dir/$lib.tar.gz"
dir="$sources_base_dir/$platform/$lib"
if [ ! -d "$dir" ] ; then
  echo "$$ unpack tarball to $dir"
  mkdir -p "$dir" 2>/dev/null
  tar -xzf "$tarball" -C "$sources_base_dir/$platform"
fi
# ls -ld "$dir"

###########################################################
#### configure
###########################################################

case "$lib" in
$RAPTOR)
	archive=libraptor2.a
	;;
$RASQAL)
	archive=librasqal.a
	;;
$REDLAND)
	archive=librdf.a
	;;
*)
	echo "ERROR: unknown lib: $lib" 1>&2
	exit 1
	;;
esac

export PREFIX="$(pwd)/$build_base_dir/$platform"
mkdir -p "$PREFIX" 2>/dev/null
cd "$cwd" ; cd "$sources_base_dir/$platform/$lib"

if [ ! -f "config.log" ] ; then # configure
  echo "$$ $(pwd)/configure ..."
  ARCH="-arch ${platform:4}"

  case "$platform" in
  Mac-*)
    export MACOSX_DEPLOYMENT_TARGET="10.6"

    PKG_CONFIG_PATH="/usr/lib/pkgconfig"
    # add siblings' pc
    PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
    export PKG_CONFIG_PATH
    export CFLAGS="-std=c99 $ARCH -pipe"
    export CPPFLAGS="$CFLAGS"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="$ARCH"
    # force sqlite use without pkg-config lookup
    export SQLITE_CFLAGS="-I${SDKROOT}/usr/include"
    export SQLITE_LIBS="-L${SDKROOT}/usr/lib -lsqlite3"

    # echo "MAC platform: $platform" 1>&2
    case "$lib" in
    $RAPTOR)
      ./configure --prefix="$PREFIX" --with-www=none 1> configure.stdout 2> configure.stderr
      ;;
    $RASQAL)
      pkg-config --exists raptor2       || { echo "$$ raptor2 is not installed (needed by ./configure)" && exit 1; }
      ./configure --prefix="$PREFIX" --with-decimal=none 1> configure.stdout 2> configure.stderr
      ;;
    $REDLAND)
      pkg-config --exists raptor2       || { echo "$$ raptor2 is not installed (needed by ./configure)" && exit 1; }
      pkg-config --exists rasqal        || { echo "$$ rasqal is not installed (needed by ./configure)" && exit 1; }
      ./configure --prefix="$PREFIX" --disable-modular --with-sqlite=yes --without-mysql --without-postgresql --without-virtuoso --without-bdb 1> configure.stdout 2> configure.stderr
      ;;
    *)
      echo "ERROR: unknown lib: $lib" 1>&2
      exit 1
      ;;
    esac
    ;;
  iOS-*)
    # echo "iOS platform: $platform" 1>&2

    PLATFORM_NAME='iPhoneOS'

    unset CPATH
    unset C_INCLUDE_PATH
    unset CPLUS_INCLUDE_PATH
    unset OBJC_INCLUDE_PATH
    unset LIBS
    unset DYLD_FALLBACK_LIBRARY_PATH
    unset DYLD_FALLBACK_FRAMEWORK_PATH

    export HOST_DARWIN_VER=$(uname -r)
    export HOST_ARCH=$(uname -m)
    export XCODE="$(xcode-select --print-path)"
    export DEVROOT="${XCODE}/Platforms/${PLATFORM_NAME}.platform/Developer"

    if [ ! -d "$DEVROOT" ]; then
      echo "$$ There is no SDK at \"$DEVROOT\""
      exit 1
    fi

    LATEST=$(ls -1r "$DEVROOT/SDKs/" | head -1)
    export SDKROOT="${DEVROOT}/SDKs/$LATEST"
    SDKVER='x.x'

    if [ ! -d "$SDKROOT" ] ; then
      echo "$$ The SDK could not be found. Directory \"$SDKROOT\" does not exist."
      exit 1
    fi

    PKG_CONFIG_PATH="${SDKROOT}/usr/lib/pkgconfig:${DEVROOT}/usr/lib/pkgconfig"
    # add siblings' pc
    PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
    export PKG_CONFIG_PATH

    export CFLAGS="-std=c99 $ARCH -pipe --sysroot=$SDKROOT -isysroot $SDKROOT -I${SDKROOT}/usr/include -I${DEVROOT}/usr/include"
    export CPPFLAGS="$CFLAGS"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="--sysroot=$SDKROOT -isysroot $SDKROOT -L${SDKROOT}/usr/lib/system -L${SDKROOT}/usr/lib"

    # force sqlite use without pkg-config lookup
    export SQLITE_CFLAGS="-I${SDKROOT}/usr/include"
    export SQLITE_LIBS="-L${SDKROOT}/usr/lib -lsqlite3"

    # set paths
    export CC=/usr/bin/gcc
    unset CPP         # configure uses "$CC -E" if CPP is not set, which is needed for many configure scripts. So, DON'T set CPP

    common_opts="--build=$HOST_ARCH-apple-darwin$HOST_DARWIN_VER --host=$HOST_ARCH-apple-darwin --enable-static --disable-shared ac_cv_file__dev_zero=no ac_cv_func_setpgrp_void=yes"
    case "$lib" in
    $RAPTOR)
      ./configure --prefix="$PREFIX" $common_opts --with-www=none 1> configure.stdout 2> configure.stderr
      ;;
    $RASQAL)
      pkg-config --exists raptor2       || { echo "$$ raptor2 is not installed (needed by ./configure)" && exit 1; }
      ./configure --prefix="$PREFIX" $common_opts --with-decimal=none 1> configure.stdout 2> configure.stderr
      ;;
    $REDLAND)
      pkg-config --exists raptor2       || { echo "$$ raptor2 is not installed (needed by ./configure)" && exit 1; }
      pkg-config --exists rasqal        || { echo "$$ rasqal is not installed (needed by ./configure)" && exit 1; }
      ./configure --prefix="$PREFIX" $common_opts --disable-modular --with-sqlite=yes --without-mysql --without-postgresql --without-virtuoso --without-bdb 1> configure.stdout 2> configure.stderr
      ;;
    *)
      echo "ERROR: unknown lib: $lib" 1>&2
      exit 1
      ;;
    esac
    ;;
  *)
    echo "ERROR: unknown platform: $platform" 1>&2
    exit 2
    ;;
  esac
fi # configure

###########################################################
#### make
###########################################################

if [ ! -f "$cwd/$build_base_dir/$platform/lib/$archive" ] ; then
  echo "$$ $(pwd)/make install ..."
#  grep prefix= config.log
  make install 1> make.stdout 2> make.stderr
  if [ $? -ne 0 ] ; then
    echo "make install failed ($?):"
    cat make.stderr
  fi
fi

# echo $$ finish $@
