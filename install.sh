#!/bin/bash

set -e

compiler_prefix="x86_64-linux-gnu"
dir="/usr/local/"
install_dir=
arch=x86_64

while getopts ":c:d:a:" OPT; do
    case ${OPT} in
        a)
            arch=$OPTARG
            ;;
        c)
            compiler_prefix=$OPTARG
            ;;
        d)
            dir=$OPTARG
            ;;
    esac
done

install_dir=${dir}/${compiler_prefix}

#$1 rep
#$2 tag
#$3 compile option
function compile_source() {
    git clone https://github.com/$1 tmp
    cd tmp
    git checkout -b br $2
    mkdir build && cd build
    cmake .. -DCMAKE_C_COMPILER=${compiler_prefix}-gcc \
        -DCMAKE_CXX_COMPILER=${compiler_prefix}-g++ \
        -DCMAKE_STAGING_PREFIX=${install_dir} \
        -DCMAKE_PREFIX_PATH=${install_dir} \
        $3
    # github-hosted runners has 2 core
    make -j4 && sudo make install
    cd ../../
    rm -rf tmp
}

function build_openssl() {
    echo "Installing openssl (1.1.1)"
    if [ $compiler_prefix == "x86_64-linux-gnu" ]; then
        sudo apt-get install -y openssl libssl-dev
    else
        git clone -b OpenSSL_1_1_1 https://gitee.com/youngspring/openssl.git
        cd openssl
        mkdir -p ${install_dir}/openssl/ssl
        ./Configure linux-${arch} no-asm shared \
            --prefix=${install_dir}/ \
            --openssldir=${install_dir}/openssl/ssl \
            --cross-compile-prefix=${compiler_prefix}- \
            --with-zlib-include=${install_dir}/zlib/include \
            --with-zlib-lib=${install_dir}/zlib/lib
        make clean
        make -j4
        make install_sw
        make clean
        cd ../
    fi
}

function build_zlog() {
    git clone -b 1.2.15 https://github.com/HardySimpson/zlog.git
    cd zlog
    make CC=${compiler_prefix}-gcc
    if [ $compiler_prefix == "x86_64-linux-gnu" ]; then
        sudo make install
        sudo make PREFIX=${install_dir} install
    else
        sudo make PREFIX=${install_dir} install
    fi
}

build_zlog
compile_source madler/zlib.git v1.2.11
compile_source akheron/jansson.git v2.14 "-DJANSSON_BUILD_DOCS=OFF -DJANSSON_EXAMPLES=OFF"
build_openssl 
compile_source neugates/nng.git neuron/v1.5.2 "-DBUILD_SHARED_LIBS=OFF -DNNG_TESTS=OFF"
compile_source benmcollins/libjwt.git v1.13.1 "-DENABLE_PIC=ON -DBUILD_SHARED_LIBS=OFF"
compile_source neugates/MQTT-C.git HEAD "-DCMAKE_POSITION_INDEPENDENT_CODE=ON -DMQTT_C_OpenSSL_SUPPORT=ON -DMQTT_C_EXAMPLES=OFF"

if [ $compiler_prefix == "x86_64-linux-gnu" ]; then
    compile_source google/googletest.git release-1.11.0
fi
