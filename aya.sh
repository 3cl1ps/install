#!/bin/bash
source repos
# AYA build script for Ubuntu & Debian 9 v.3 (c) Decker (and webworker)
berkeleydb () {
    AYA_ROOT=$(pwd)
    AYA_PREFIX="${AYA_ROOT}/db4"
    mkdir -p $AYA_PREFIX
    wget -N 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
    echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef db-4.8.30.NC.tar.gz' | sha256sum -c
    tar -xzvf db-4.8.30.NC.tar.gz
    cd db-4.8.30.NC/build_unix/

    ../dist/configure -enable-cxx -disable-shared -with-pic -prefix=$AYA_PREFIX

    make install
    cd $AYA_ROOT
}

buildAYA () {
    git pull
    ./autogen.sh
    ./configure LDFLAGS="-L${AYA_PREFIX}/lib/" CPPFLAGS="-I${AYA_PREFIX}/include/" --with-gui=no --disable-tests --disable-bench --without-miniupnpc --enable-experimental-asm --enable-static --disable-shared --with-incompatible-bdb
    make -j$(nproc)
}

mkdir ~/.aryacoin
rm ~/.aryacoin/aryacoin.conf
echo "txindex=1" >> ~/.aryacoin/aryacoin.conf
echo "server=1" >> ~/.aryacoin/aryacoin.conf
echo "daemon=1" >> ~/.aryacoin/aryacoin.conf
echo "rpcuser=`head -c 32 /dev/urandom | base64`" >> ~/.aryacoin/aryacoin.conf
echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/.aryacoin/aryacoin.conf
echo "bind=127.0.0.1" >> ~/.aryacoin/aryacoin.conf
echo "rpcbind=127.0.0.1" >> ~/.aryacoin/aryacoin.conf
echo "rpcallowip=127.0.0.1" >> ~/.aryacoin/aryacoin.conf
echo "changeaddress=" >> ~/.aryacoin/aryacoin.conf
chmod 0600 ~/.aryacoin/aryacoin.conf

cd ~
git clone https://github.com/sillyghost/AYAv2.git
cd AYAv2/
git checkout ${repos[AYA,1]}
berkeleydb
buildAYA
echo "Done building AYA!"
