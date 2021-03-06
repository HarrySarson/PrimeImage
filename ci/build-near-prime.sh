#!/bin/bash

set -e

if ! command -v lzip ; then
    echo "Building near prime's dependancies requires lzip"
    exit 1
fi

if ! command -v m4 ; then
    echo "Building near prime's dependancies requires m4"
    exit 1
fi

mkdir -p ci/build
pushd ci/build

# Get emsdk
if [[ ! -d emsdk ]]; then
    git clone https://github.com/emscripten-core/emsdk.git
fi
git pull
pushd emsdk
if [[ ! -d emscripten/1.38.30 ]] ; then
    ./emsdk install sdk-1.38.30-64bit
fi
./emsdk activate sdk-1.38.30-64bit
source ./emsdk_env.sh
popd

# download

wget https://gmplib.org/download/gmp/gmp-6.1.2.tar.lz

if [[ ! -d gmp-wasm ]]; then
    mkdir gmp-wasm
    tar xf gmp-6.1.2.tar.lz -C gmp-wasm --strip-components=1

    pushd gmp-wasm
    sed -i '2igmp_asm_syntax_testing=no' configure

    emconfigure ./configure --disable-assembly --disable-shared --prefix=$EMSCRIPTEN/system

    echo '#define HAVE_MEMSET 1' >> config.h
    echo '#define HAVE_STRNLEN 1' >> config.h
    echo '#define HAVE_VSNPRINTF 1' >> config.h

    # Print include paths of compilers for debugging
    echo | gcc -E -Wp,-v -
    echo | clang -E -Wp,-v -

    if [[ ! -d $EMSDK/clang/lib/clang/6.0.1/include ]]; then
        mkdir -p $EMSDK/clang/lib/clang/6.0.1/include
        GCCVER=$(gcc -dumpversion)
        echo "symlinking usr/lib/gcc/x86_64-linux-gnu/$GCCVER/include/*"
        ln -s /usr/lib/gcc/x86_64-linux-gnu/$GCCVER/include/* $EMSDK/clang/lib/clang/6.0.1/include
        echo "symlinking usr/lib/gcc/x86_64-linux-gnu/$GCCVER/include-fixed/*"
        ln -s /usr/lib/gcc/x86_64-linux-gnu/$GCCVER/include-fixed/* $EMSDK/clang/lib/clang/6.0.1/include
    fi

    make -j 2
    popd
fi

pushd gmp-wasm
make install

popd
popd
